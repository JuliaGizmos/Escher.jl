

import Base: >>>

export bubble,
       stopbubbling,
       intent,
       constant,
       pairwith,
       sampler,
       output,
       trigger!,
       collector,
       watch!,
       subscribe

### Behavior ###


"""
A Behavior is a tile that can result in a stream of values.

The stream of values can be given intents, put into signals, used to trigger updates from other behaviors.

See `subscribe`, `intent`, `sampler` and `capture`
"""
abstract Behavior <: Tile


### Intent ###


"""
An intent is a transformation applied to the stream of values coming from a behavior

The purpose of an intent is to turn widget messages into types in the business logic of the application

For example, a simple intent is the pair with intent, if you have a list of buttons and would like to know which button was clicked as well as the mouse button that was pressed, you can attach the `pairwith` intent to the buttons:

    clicks = Signal(Tuple, (0, leftbutton))
    vbox([pairwith(idx, btn) >>> clicks for (idx, btn) in enumerate(buttons)])

Here the `clicks` signal will update to a tuple containing the index of the button clicked and the mouse button clicked whenever any of the buttons is clicked by the user.
"""
abstract Intent

@api intent => WithIntent <: Behavior begin
    arg(intent::Intent, doc="The intent")
    curry(tile::Behavior, doc="The behavior to apply the intent to")
end

render(i::WithIntent, state) = render(i.tile, state)

"""
Attach an intent to a behavior. A widget or a behavior has a default intent defined by the `default_intent` generic function. When another intent is attached to a behavior, it gets chained to the default intent.

Attaching an intent to a behavior results in a new behavior.
"""
intent(i::Intent, tile::Behavior) =
    WithIntent(Chained(i, default_intent(tile)), tile)
intent(i::Intent) = t -> intent(i, t)

"""
The default intent of a behavior. For example, a clickable behavior will convert JSON messages to the appropriate constants, `leftbutton`, `rightbutton`, `scrollbutton`.
"""
default_intent(::Behavior) = identity
default_intent(t::WithIntent) = t.intent

"""
takes an intent and the value and applies the intent to the value
"""
function interpret
end

"""
Identity intent. Does not change the input behavior.
"""
immutable Id <: Intent end
const identity = Id()

interpret(::Id, x) = x

"""
Apply two intents
"""
immutable Chained <: Intent
    intent1::Intent
    intent2::Intent
end

Chained(::Id, ::Id) = identity
Chained(a::Intent, ::Id) = a
Chained(::Id, a::Intent) = a
chain(x::Intent,y::Intent) = Chained(x, y)

interpret(i::Chained, x) =
    interpret(i.intent1, interpret(i.intent2, x))

"""
An intent to convert a value to type T.
"""
immutable ToType{T} <: Intent end

interpret{T}(::ToType{T}, x) = convert(T, x)
interpret{T<:Real}(::ToType{T}, x::AbstractString) = parse(T, x)
interpret{T<:Real}(::ToType{T}, x::Void) = zero(T)
interpret(::ToType{AbstractString}, x::Void) = ""

"""
Ignore the value from the behavior and replace it with a constant
"""
immutable Const{T} <: Intent
    value::T
end

constant(x) = Const(x)
interpret(x::Const, _) = x.value

"""
Intent to pair with a constant
"""
immutable PairWith{T} <: Intent
    value::T
end

pairwith(x) = PairWith(x)
interpret(x::PairWith, _) = x.value => _

"""
A function intent
"""
immutable ApplyIntent <: Intent
    f::Union{Function, Type}
end

intent(f::Union{Function, Type}, tile::Tile) = intent(ApplyIntent(f), tile)

interpret(i::ApplyIntent, x) = i.f(x)

@api bubble => (Bubble <: Behavior) begin
    doc(md""" Give a name to a behavior and allow outer tiles to listen to updates""")
    arg(name::Symbol, doc="The name to associate with the bubbled event")
    arg(tile::Behavior, doc="Behavior to bubble")
    kwarg(bubbles::Bool=true, doc="Enable/disable bubbling")
    kwarg(index::Int=0, doc="Index in an aggregate")
end

default_intent(b::Bubble) = default_intent(b.tile)

render(tile::Bubble, state) = begin
    withlastchild(render(tile.tile, state)) do elem
        elem & @d(:attributes => @d(
            :bubbles => boolattr(tile.bubbles),
            :name=>tile.name,
            :index=>tile.index,
            :id=>"signal-"*string(tile.name)),
        )
    end
end

@api stopbubbling => (StopBubbling <: Behavior) begin
    doc(md"""Stop bubbling of named events to parents.
             This can be used to stop bubbling set up via `bubble`."""
    )
    arg(tile::Tile, doc="Tile to contain the updates inside.")
    arg(names::Vector, doc="Names of the widget/behavior to stop.")
end

render(tile::StopBubbling, state) =
    render(tile.tile, state) <<
        Elem("stop-bubbling", names=tile.names)


### Collective Intents ###


@api sampler => (Sampler <: Intent) begin
    doc(md"""A means to make forms. Use `watch!` and `trigger!` to specify which
         widgets/behavior to watch and which widgets/behavior trigger the form.
         """)
    typedarg(triggers::Dict=Dict(), doc="Internal store for trigger elements.")
    arg(watches::Dict=Dict(), doc="Internal store for watches elements.")
end

interpret(s::Sampler, msg) = begin
    d = Dict()
    d[:_trigger] = symbol(msg["_trigger"])

    for (name, interp) in s.triggers
      if(haskey( msg, string(name)))
        d[name] = interpret(interp, msg[string(name)])
      end
    end

    for (name, interp) in s.watches
        @show name, interp
       d[name] = interpret(interp, msg[string(name)])
    end

    return d
end

watch!(sampler::Sampler, name::Symbol, tile) = begin
    sampler.watches[name] = default_intent(tile)
    bubble(name, wrapbehavior(tile))
end

watch!(sampler::Sampler, tile::Bubble) = begin
    sampler.watches[tile.name] = default_intent(tile)
    tile
end

watch!(sampler::Sampler, name) = t -> watch!(sampler, name, t)

@apidoc watch! => (Tile) begin
    doc("""Make a sampler watch a widget/behavior. Returns the input
         widget/behavior.""")
    arg(sampler::Sampler, doc="The sampler to add the watch on.")
    arg(name::Symbol, doc="A name used for bubbling updates")
    curry(tile::Behavior, doc="The widget/behavior.")
end

trigger!(sampler::Sampler, name::Symbol, tile) = begin
    sampler.triggers[name] = default_intent(tile)
    bubble(name, wrapbehavior(tile))
end

trigger!(sampler::Sampler, tile::Bubble) = begin
    sampler.triggers[tile.name] = default_intent(tile)
    tile
end

trigger!(sampler::Sampler, name::Symbol) = t -> trigger!(sampler, name, t)

@apidoc trigger! => (Tile) begin
    doc("""Make a sampler trigger on a change to a widget/behavior. Returns the
         input widget/behavior.""")
    arg(sampler::Sampler, doc="The sampler to add the trigger on.")
    arg(name::Symbol, doc="A name used for bubbling updates")
    curry(tile::Tile, doc="The widget/behavior.")
end


@api collector => (Collector <: Intent) begin
    doc(md"""Collect stream of values from many behaviors into one steam.
    The `aggregator` returns an intent which can then be applied to a tile that encapsulates
    all the aggregated behaviors
    """)
    typedarg(name::Symbol=:_collector, doc="A name for the collector. Events bubbling from collected tiles are matched to a collector using this name.")
    arg(intents::Vector=Intent[], doc="Internal storage of Intents of collected behaviors")
end

watch!(agg::Collector, tile) = begin
    push!(agg.intents, default_intent(tile))
    bubble(agg.name, tile, index=length(agg.intents))
end

immutable OuterListener{T <: Union{Sampler, Collector}} <: Behavior
    spec::T
    tile::Tile
end

intent(c::Union{Sampler, Collector}, tile::Tile) =
    WithIntent(c, OuterListener(c, tile))

render(c::OuterListener{Sampler}, state) = begin
    render(c.tile, state) <<
        Elem("signal-sampler", signals=collect(keys(c.spec.watches)), triggers=collect(keys(c.spec.triggers)))
end

render(c::OuterListener{Collector}, state) = begin
    render(c.tile, state) <<
        Elem("signal-collector", collectorName=c.spec.name)
end

immutable Collect <: Behavior
    collector::Collector
    index::Int
    tile::Behavior
end
default_intent(c::Collect) = default_intent(c.tile)

render(c::Collect, state) = begin
    withlastchild(render(c.tile, state)) do child
        child << Elem("signal-collect", collectorName=c.collector.name, index=c.index)
    end
end

# Interpret a message from a collectee
interpret(a::Collector, x) = begin
    interpret(a.intents[x["index"]], x["value"])
end


### Subscription ###


# """
# Subscribe to the stream of values from a behavior
# """
@api subscribe => (Subscription <: Tile) begin
    arg(receiver::Signal)
    arg(intent::Intent)
    arg(tile::Tile)
end

subscribe(s::Signal, t::Behavior) =
    subscribe(s, default_intent(t), t)

subscribe(s::Signal, t::WithIntent) =
    subscribe(s, t.intent, t.tile)

subscribe(s::Signal, t::OuterListener) =
    subscribe(s, t.spec, t)

subscribe(c::Collector, tile::Behavior) = begin
    push!(c.intents, default_intent(tile))
    Collect(c, length(c.intents), tile)
end


@apidoc subscribe => (Subscription <: Behavior) begin
    doc(md"""Subscribe to updates from a widget/behavior. `>>>` is an infix
             alias to subscribe"""
    )
    arg(
        input::Signal,
        doc=md"""The input signal to update. See
            [Reactive.jl documentation](http://julialang.org/Reactive.jl/#a-tutorial-introduction)
            for more on input signals."""
    )
    arg(tile::Tile, doc="The widget/behavior.")
    kwarg(
        absorb::Bool=true,
        doc="If set to true, the update event will not bubble out from the widget."
    )
end

render(sig::Subscription, state) =
    withlastchild(render(sig.tile, state)) do child
        # NOTE: This implementation assumes that
        # The behavior will have rendered an element "inside" the behavior-creator element
        # So this puts a constraint on the way behaviors should be implemented

        child << Elem("signal-transport", signalId=makeid((sig.receiver, sig.intent)))
    end

(>>>)(t::Tile, s::Union{Signal, Collector}) = subscribe(s, t)

# This allows easy rendering of subscriptions
convert(::Type{Node}, sub::Subscription) = render(sub, Dict())

import Base.Random: UUID, uuid4

const object_to_id = Dict()
const id_to_object = Dict()

"""
Create a unique ID for a (Signal, Intent) pair
"""
makeid(object) = begin
    if haskey(object_to_id, object)
        # TODO ensure connection & reject / collect
        return object_to_id[object]
    else
        id = haskey(object_to_id, object) ?
            object_to_id[object] : string(rand(UInt128))
        object_to_id[object] = id
        id_to_object[id] = object
        return id
    end
end

"""
Given the unique ID created by makeid, return the object associated with it.
"""
fromid(id) = id_to_object[id]
