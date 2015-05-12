
import Base: $

export stoppropagation,
       interpreter,
       constant,
       pairwith,
       pairwithindex,
       subscribe,
       samplesignals


# First line of decoding.

decodeJSON(x) = x

# A type for facilitating dispatch for
# decodeJSON
immutable InputType{ctr}
end

decodeJSON(ctr, x) = x
decodeJSON(::InputType{:Tuple}, x) = tuple(x.data...)

# If input is a dictionary, call the constructor
decodeJSON(x::Dict) =
    haskey(x, "_ctr") ?
        decodeJSON(InputType{symbol(x["_ctr"])}(), x) : x

@doc """
A Behavior is a tile that denotes that it can
broadcast some signal
""" ->
abstract Behavior <: Tile

name(b::Behavior) = b.name

# Second line of decoding - usually in the business logic

abstract Interpreter

@api interpreter => WithInterpreter <: Behavior begin
    arg(interpreter::Interpreter)
    curry(tile::Behavior)
end
name(d::WithInterpreter) = name(d.tile)

render(d::WithInterpreter) =
    render(d.tile)

# Don't change the message
immutable Id <: Interpreter
end
const identity = Id()

interpret(dec::Id, x) = x

# Chain two interpreters together.
immutable Chained <: Interpreter
    interpreter1::Interpreter
    interpreter2::Interpreter
end

chain(d, t::WithInterpreter) =
    interpreter(Chained(d, t.interpreter), t.tile)

interpret(dec::Chained, x) =
    interpret(dec.interpreter1, interpret(dec.interpreter2, x))

# Pair with a constant
immutable ConstPair <: Interpreter
    value::Any
end

interpret(dec::ConstPair, x) = (x, dec.value)

pairwith(x, tile::Tile) = interpreter(ConstPair(x), tile)
pairwith(x) = interpreter(ConstPair(x))
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

constant(x, tile::Tile) = interpreter(Const(x), tile)
constant(x) = interpreter(Const(x))
constant(xs::AbstractArray, tiles::AbstractArray) = map(constant, xs, tiles)
constant(x, tiles::AbstractArray) = map(constant(x), tiles)

# Apply a function
immutable InterpreterFn <: Interpreter
    f::Function
end
interpreter(f::Function, tile::Tile) = interpreter(InterpreterFn(f), tile)
interpret(dec::InterpreterFn, x) = dec.f(x)

# Apply a function with some constant partial args
# For efficiency, the function must be defined outside
# of any signal functions. i.e. no point creating
# ad-hoc functions

immutable InterpreterPartialFn <: Interpreter
    f::Function
    args::Tuple
end
partial(f::Function, args::Tuple, tile) =
    interpreter(InterpreterPartialFn(f, args), tile)

interpret(dec::InterpreterPartialFn, x) = dec.f(dec.args..., x)

### Send a signal update to the Julia side

immutable Subscription <: Tile
    tile::Tile
    name::Symbol # Name of the signal update on the front-end
    receiver::@compat Tuple{Interpreter, Input}
end

subscribe(t::Tile, name, s; absorb=true) =
    Subscription(t, name, s) |>
       (x -> absorb ? stoppropagation(x, name) : x)

subscribe(t::Behavior, s::Input; absorb=true) =
    subscribe(t, name(t), (identity, s), absorb=absorb)
subscribe(t::Behavior, s::(@compat Tuple{Interpreter, Input}); absorb=true) =
    subscribe(t, name(t), s, absorb=absorb)

render(sig::Subscription) =
    render(sig.tile) <<
        Elem("signal-transport",
            name=sig.name, signalId=setup_transport(sig.receiver))


setup_transport(x) =
    error("Looks like there is no trasport set up")

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


(>>>)(t::Behavior, s::Input) = subscribe(t, (identity, s))

# TODO: Use a different operator with lesser precedence than >>>
(>>>)(t::Behavior, f::Function) = interpreter(f, t)
(>>>)(t::WithInterpreter, f::Function) = chain(InterpreterFn(f), t)
(>>>)(t::WithInterpreter, s::Input) = subscribe(t, (t.interpreter, s))

