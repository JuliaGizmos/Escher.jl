import Base: >>>

export hasstate,
       clickable,
       selectable,
       draggable,
       resizable,
       leftbutton,
       rightbutton,
       scrollbutton

abstract Behaviour <: Tile

subscribe(t::Behaviour, s::Input; absorb=true) =
    subscribe(t, t.name, s, absorb=absorb)

(>>>)(t::Behaviour, s::Input) = subscribe(t, s)

immutable WithState{attr} <: Behaviour
    name::Symbol
    tile::Tile
    trigger::String
end

render{attr}(t::WithState{attr}) =
    render(t.tile) << Elem("watch-state",
        attributes=[:name=>t.name, :attr=>attr, :trigger=>t.trigger])


hasstate(tile::Tile; name=:_state, attr="value", trigger="change") =
    WithState{symbol(attr)}(name, tile, trigger)

# Sample a bunch of signals upon changes to another bunch of signals
# Returns a signal of dict of signal values
@api samplesignals => SignalSampler <: Behaviour begin
    arg(signals::AbstractArray)
    arg(triggers::AbstractArray)
    curry(tile::Tile)
    typedkwarg(name::Symbol=:_sampler)
end

samplesignals(tosample::Symbol, triggers::Symbol, x...; name=:_sampler) =
    samplesignals([tosample], [triggers], x...; name=name)
samplesignals(tosample::Symbol, triggers, x...; name=:_sampler) =
    samplesignals([tosample], [triggers], x...; name=name)
samplesignals(tosample, triggers::Symbol, x...; name=:_sampler) =
    samplesignals(tosample, [triggers], x...; name=name)

render(sig::SignalSampler) =
    render(sig.tile) <<
        Elem("signal-sampler",
            name=sig.name,
            signals=sig.signals,
            triggers=sig.triggers)

abstract MouseButton

@terms MouseButton begin
    leftbutton => LeftButton
    rightbutton => RightButton
    scrollbutton => ScrollButton
end

@api clickable => Clickable <: Behaviour begin
    typedarg(buttons::AbstractArray=[leftbutton])
    curry(tile::Tile)
    kwarg(name::Symbol=:_clicks)
end

button_number(::LeftButton) = 1
button_number(::RightButton) = 2
button_number(::ScrollButton) = 3

render(c::Clickable) =
    render(c.tile) << Elem("clickable-behaviour", name=c.name,
                        buttons=string(map(button_number, c.buttons)))


@api selectable => Selectable <: Behaviour begin
    curry(tile::Tile)
    kwarg(name::Symbol=:_clicks)
end

render(s::Selectable) =
    render(s.tile) << Elem("selectable-behaviour", name=s.name)


convert(::Type{MouseButton}, x::Int) =
    try [leftbutton, rightbutton, scrollbutton][x]
    catch error("Invalid mouse button code: $x")
    end

abstract MouseState

@terms MouseState begin
    mousedown => MouseDown
    mouseup => MouseUp
end

@api hoverable => Hoverable <: Behaviour begin
    typedarg(get_coords::Bool=false)
    curry(tile::Tile)
    kwarg(name::Symbol=:_hover)
end

immutable Hover
    state::MouseState
    position::(Float64, Float64)
end

immutable Resizable <: Behaviour
    name::Symbol
    tile::Tile
    container::Tile
end

immutable Size
    proportions::(Float64, Float64)
end

resizable(tile, container; name=:_size) = Resizable(name, tile, container)

immutable Draggable <: Behaviour
    name::Symbol
    tile::Tile
    container::Tile
end

draggable(tile, container; name=:_drag) = Draggable(name, tile, container)

immutable Drag
    fraction::(Float64, Float64)
end

immutable Sortable <: Behaviour
    name::Symbol
    tile::AbstractArray
end

immutable PositionSwap
    swap::(Int, Int)
end

immutable Editable <: Behaviour
    name::Symbol
    tile::Tile
end

## UI-side global channels
import Base: send, recv
export send, recv, wire

immutable ChanSend <: Tile
    chan::Symbol
    watch::Symbol
    tile::Tile
end
send(chan::Symbol, b::Behaviour) =
    ChanSend(chan, b.name, b)

render(chan::ChanSend) =
    render(chan.tile) <<
        Elem("chan-send",
            chan=chan.chan, watch=chan.watch)


immutable ChanRecv <: Tile
    chan::Symbol
    attr::Symbol
    tile::Tile
end
recv(chan::Symbol, t, attr) =
    ChanRecv(chan, attr, t)

render(chan::ChanRecv) =
    render(chan.tile) <<
        Elem("chan-recv",
            chan=chan.chan, attr=chan.attr)


wire(a::Behaviour, b, chan, attribute) =
    send(chan, a), recv(chan, b, attribute)
