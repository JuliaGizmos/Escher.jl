
import Base: >>>

export bubble,
       stopbubbling,
       addinterpreter,
       constant,
       pairwith,
       sampler,
       plugsampler,
       trigger!,
       watch!,
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

wrapbehavior(b::Behavior) = b

## Interpreting a message ##

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

@apidoc addinterpreter => (WithInterpreter <: Behavior) begin
    doc("Attach an interpreter to a widget/behavior.")
    arg(interpreter::Interpreter, doc="An interpreter.")
    curry(tile::Behavior, doc="The widget/behavior.")
end

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

@apidoc pairwith => (WithInterpreter <: Behavior) begin
    doc("An interpreter that pairs the updated value with a constant.")
    arg(constant::Any, doc="The constant.")
    curry(tile::Tile, doc="The widget/behavior.")
end

# Instead of the signal value, use a constant
immutable Const <: Interpreter
    value::Any
end

interpret(dec::Const, _) = dec.value

constant(x, tile) = addinterpreter(Const(x), tile)
constant(x) = addinterpreter(Const(x))

@apidoc constant => (WithInterpreter <: Behavior) begin
    doc("""A constant interpreter. Ignores updated values and interpret them as
           a constant.""")
    arg(x::Any, doc="The constant.")
    curry(tile::Tile, doc="The widget/behavior.")
end

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

render(d::WithInterpreter, state) = render(d.tile, state)

#
# Subscribe to a signal and register an interpreter
#

@api subscribe => (Subscription <: Tile) begin
    arg(tile::Behavior)
    arg(name::Symbol)
    arg(receiver::@compat Tuple{Interpreter, Input})
end

subscribe(t::Behavior, s::Input) =
    subscribe(t, name(t), (default_interpreter(t), s))

subscribe(t::Behavior, s::(@compat Tuple{Interpreter, Input})) =
    subscribe(t, name(t), s, absorb=absorb)

subscribe(t::WithInterpreter, s::Input) =
    subscribe(t.tile, name(t), (t.interpreter, s))

@apidoc subscribe => (Subscription <: Tile) begin
    doc(md"""Subscribe to updates from a widget/behavior. `>>>` is an infix
             alias to subscribe"""
    )
    arg(tile::Tile, doc="The widget/behavior.")
    arg(
        input::Input,
        doc=md"""The input signal to update. See
            [Reactive.jl documentation](http://julialang.org/Reactive.jl/#a-tutorial-introduction)
            for more on input signals."""
    )
    kwarg(
        absorb::Bool,
        doc="If set to true, the update event will not bubble out from the widget."
    )
end

render(sig::Subscription, state) =
    render(sig.tile, state) <<
        Elem("signal-transport",
            # Note: setup_transport here adds (interpreter, input) pair
            # to a dict, returns the key - this fn is idempotent
            name=sig.name, signalId=setup_transport(sig.receiver))

# Default definition of setup_transport
setup_transport(x) = makeid(x)

(>>>)(b::Behavior, s::Input) = subscribe(b, s)

### Sampling

@api sampler => (Sampler <: Interpreter) begin
    doc(md"""A means to make forms. Use `watch!` and `trigger!` to specify which
         widgets/behavior to watch and which widgets/behavior trigger the form.
         """)
    arg(triggers::Dict=Dict(), doc="Internal store for trigger elements.")
    arg(watched::Dict=Dict(), doc="Internal store for watched elements.")
end

interpret(s::Sampler, msg) = begin
    try
        d = Dict()
        d[:_trigger] = symbol(msg["_trigger"])
        
        for (name, interp) in s.triggers
          if(haskey( msg, string(name )))
            d[name] = interpret(interp, msg[string(name)])
          end
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
    bubble(wrapbehavior(tile))
end

watch!(sampler::Sampler) = t -> watch!(sampler, t)

@apidoc watch! => (Tile) begin
    doc("""Make a sampler watch a widget/behavior. Returns the input
         widget/behavior.""")
    arg(sampler::Sampler, doc="The sampler to add the watch on.")
    curry(tile::Tile, doc="The widget/behavior.")
end

trigger!(sampler::Sampler, tile) = begin
    sampler.triggers[name(tile)] = default_interpreter(tile)
    bubble(wrapbehavior(tile))
end

trigger!(sampler::Sampler) = t -> trigger!(sampler, t)

@apidoc trigger! => (Tile) begin
    doc("""Make a sampler trigger on a change to a widget/behavior. Returns the
         input widget/behavior.""")
    arg(sampler::Sampler, doc="The sampler to add the trigger on.")
    curry(tile::Tile, doc="The widget/behavior.")
end

@api plugsampler => (Sampled <: Behavior) begin
    doc("""Attach a sampler to a tile containing the widgets the sampler deals
           with.""")
    arg(sampler::Sampler, doc=md"The `sampler`." )
    curry(tile::Tile, doc="The tile to attach the sampler to.")
    kwarg(name::Symbol=:_sampled, doc="The name to identify the behavior.")
end

render(s::Sampled, state) =
    render(s.tile, state) <<
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
        id = haskey(signal_to_id, sig) ?
            signal_to_id[sig] : string(rand(Uint128))
        id_to_signal[id] = sig
        return id
    end
end

fromid(id) = id_to_signal[id]

# TODO: bubble can be applied to Widget - which won't work
# Thing to do would be to not subtype Widget as Behavior
@api bubble => (Bubble <: Behavior) begin
    doc(md"""Make updates bubble from the behavior. Used internally by sampler.""")
    arg(tile::Behavior, doc="Behavior to bubble")
    kwarg(bubbles::Bool=true, doc="Enable/disable bubbling")
end

name(b::Bubble) = b.tile
default_interpreter(b::Bubble) = default_interpreter(t.tile)

# This actually sets the property on the widget and not the behavior
# Unfortunate that there is no easy way to do this.
render(tile::Bubble, state) =
    render(tile.tile, state) & @d(:bubbles => boolattr(tile.bubbles))


# Don't allow a signal to propagate outward
@api stopbubbling => (StopBubbling <: Tile) begin
    doc(md"""Stop bubbling of behavior/widget events in the web page.
             This can be used to stop bubbling set up via `bubble`."""
    )
    arg(tile::Tile, doc="Tile to contain the updates inside.")
    arg(name::Symbol, doc="Name of the widget/behavior to stop.")
end

render(tile::StopBubbling, state) =
    render(tile.tile, state) <<
        Elem("stop-propagation", names=[tile.name])

immutable SignalWrap <: Tile
    signal::Signal
end

convert(::Type{Tile}, x::Signal) = SignalWrap(x)

render(tile::SignalWrap, state) = begin
    id = "signal-" * makeid(tile.signal)
    state["embedded_signals"][id] = tile.signal
    Elem("signal-container", signalId=id)
end
