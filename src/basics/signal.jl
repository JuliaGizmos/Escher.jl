
import Base: >>>

export stoppropagation,
       addinterpreter,
       constant,
       pairwith,
       sampler,
       sample,
       trigger!,
       watch!,
       pairwithindex,
       subscribe
#=
   Note: Maybe use

   immutable MessageException <: Exception
       error::Exception
       backtrace::String
   end

   MessageException(x::Exception) =
       MessageException(x, sprint(io -> Base.show_backtrace(io, backtrace())))

=#

@doc """
A Behavior is a tile that denotes that it can
broadcast some signal
""" ->
abstract Behavior <: Tile

name(b::Behavior) = b.name

broadcast(b::Behavior) = b

## Interpreting a message from a behavior ##

abstract Interpreter

immutable WithInterpreter <: Behavior
    interpreter::Interpreter
    tile::Behavior
end

# Identity interpreter: don't change the message
immutable Id <: Interpreter end
const identity = Id()

# Chain two interpreters together.
immutable Chained <: Interpreter
    interpreter1::Interpreter
    interpreter2::Interpreter
end

Chained(::Id, ::Id) = identity
Chained(a::Interpreter, ::Id) = a
Chained(::Id, a::Interpreter) = a

addinterpreter(i::Interpreter, tile::Behavior) =
    # Chained is defined below
    WithInterpreter(Chained(i, default_interpreter(tile)), tile)
addinterpreter(i::Interpreter) = t -> addinterpreter(i, t)

default_interpreter(t::WithInterpreter) = t.interpreter


# The default interpreter for a behavior is identity
default_interpreter(::Behavior) = identity

interpret(dec::Id, x) = x

# convert to a type
immutable ToType{T} <: Interpreter end
interpret{T}(::ToType{T}, x) = convert(T, x)
interpret{T<:Integer}(::ToType{T}, x::String) =
    try parse(T, x) catch ex ex end
interpret{T<:Real}(::ToType{T}, x::Nothing) = zero(T)
interpret(::ToType{@compat AbstractString}, x::Nothing) = ""

interpret(dec::Chained, x) =
    interpret(dec.interpreter1, interpret(dec.interpreter2, x))

# Pair with a constant
immutable PairWith <: Interpreter
    value::Any
end

interpret(dec::PairWith, x) = (x, dec.value)

pairwith(x) = addinterpreter(PairWith(x))
pairwith(x, tile::Tile) = addinterpreter(PairWith(x), tile)
pairwith(x::AbstractArray, tiles::AbstractArray) = map(pairwith, x, tiles)
pairwith(x, tiles::AbstractArray) = map(pairwith(x))

pairwithindex(tiles::AbstractVector) =
    [pairwith(i, v)
        for (i, v) in enumerate(tiles)]

pairwithindex(tiles::AbstractMatrix) =
    [pairwith((i, j), tiles[i, j])
        for i=1:size(tiles, 1), j=1:size(tiles, 2)]

# Instead of the signal value, use a constant
immutable Const <: Interpreter
    value::Any
end

interpret(dec::Const, _) = dec.value

constant(x, tile::Tile) = addinterpreter(Const(x), tile)
constant(x) = addinterpreter(Const(x))
constant(xs::AbstractArray, tiles::AbstractArray) = map(constant, xs, tiles)
constant(x, tiles::AbstractArray) = map(constant(x), tiles)

# Apply a function
immutable InterpreterFn <: Interpreter
    f::Function
end
addinterpreter(f::Function, tile::Tile) = addinterpreter(InterpreterFn(f), tile)
interpret(dec::InterpreterFn, x) = dec.f(x)

# Apply a function with some constant partial args
# For efficiency, the function must be defined outside
# of any signal functions. i.e. no point creating
# ad-hoc functions

immutable InterpreterThunk <: Interpreter
    f::Function
    args::Tuple
end
partial(f::Function, args::Tuple, tile) =
    addinterpreter(InterpreterThunk(f, args), tile)

interpret(dec::InterpreterThunk, x) = dec.f(dec.args..., x)


name(d::WithInterpreter) = name(d.tile)

render(d::WithInterpreter) = render(d.tile)

#
# Subscribe to a signal and register an interpreter
#

immutable Subscription <: Tile
    tile::Tile
    name::Symbol # Name of the signal update on the front-end
    receiver::@compat Tuple{Interpreter, Input}
end

subscribe(t::Tile, name, s; absorb=true) =
    Subscription(t, name, s) |>
       (x -> absorb ? stoppropagation(x, name) : x)

subscribe(t::Behavior, s::Input; absorb=true) =
    subscribe(t, name(t), (default_interpreter(t), s), absorb=absorb)

subscribe(t::Behavior, s::(@compat Tuple{Interpreter, Input}); absorb=true) =
    subscribe(t, name(t), s, absorb=absorb)

subscribe(t::WithInterpreter, s::Input; absorb=true) =
    subscribe(t.tile, name(t), (t.interpreter, s), absorb=absorb)

render(sig::Subscription) =
    render(sig.tile) <<
        Elem("signal-transport",
            # Note: setup_transport here adds (interpreter, input) pair
            # to a dict, returns the key - this fn is idempotent
            name=sig.name, signalId=setup_transport(sig.receiver))

(>>>)(b::Behavior, s::Input) = subscribe(b, s)

setup_transport(x) =
    error("Looks like there is no trasport set up")

### Sampling

@api sampler => Sampler <: Interpreter begin
    arg(triggers::Dict)
    arg(watched::Dict)
end
sampler() = Sampler(Dict(), Dict())

interpret(s::Sampler, msg) = begin
    try
        d = Dict()
        d[:_trigger] = msg["_trigger"]

        for (name, interp) in s.triggers
           d[name] = interpret(interp, msg[string(name)])
        end

        for (name, interp) in s.watched
           d[name] = interpret(interp, msg[string(name)])
        end

        return d
    catch ex
        ex
    end
end

watch!(sampler::Sampler, tile) = begin
    sampler.watched[name(tile)] = default_interpreter(tile)
    broadcast(tile)
end

watch!(sampler::Sampler) = t -> watch!(sampler, t)

trigger!(sampler::Sampler, tile) = begin
    sampler.triggers[name(tile)] = default_interpreter(tile)
    broadcast(tile)
end

trigger!(sampler::Sampler) = t -> trigger!(sampler, t)

@api sample => Sampled <: Behavior begin
    arg(sampler::Sampler)
    curry(tile::Tile)
    kwarg(name::Symbol=:_sampled)
end
render(s::Sampled) =
    render(s.tile) <<
        Elem("signal-sampler",
            name=s.name,
            signals=collect(keys(s.sampler.watched)),
            triggers=collect(keys(s.sampler.triggers)))

default_interpreter(s::Sampled) = s.sampler

## Helpers for setup_transport implementers ##

import Base.Random: UUID, uuid4

const signal_to_id = Dict()
const id_to_signal = Dict()

makeid(sig) = begin
    if haskey(signal_to_id, sig)
        # todo ensure connection
        return signal_to_id[sig]
    else
        id = get!(() -> string(uuid4()), signal_to_id, sig)
        id_to_signal[id] = sig
        return id
    end
end

fromid(id) = id_to_signal[id]

# Don't allow a signal to propagate outward
immutable StopPropagation <: Tile
    tile::Tile
    name::Symbol
end

@doc """
Stop a UI signal from propagating further.
""" ->
stoppropagation(tile::Tile, name::Symbol) =
    StopPropagation(tile, name)

render(tile::StopPropagation) =
    render(tile.tile) <<
        Elem("stop-propagation", name=tile.name)
