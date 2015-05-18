export hasstate,
       keypress,
       Key,
       nokey,
       clickable,
       selectable,
       draggable,
       resizable,
       leftbutton,
       rightbutton,
       scrollbutton


@api hasstate => WithState <: Behavior begin
    curry(tile::Tile)
    kwarg(name::Symbol=:_state)
    kwarg(attr::String="value")
    kwarg(elem::String="::parent")
    kwarg(trigger::String="change")
    kwarg(source::String="")
end

default_interpreter(::WithState) = identity

render(t::WithState) =
    render(t.tile) <<
        Elem(
            "watch-state",
            name=t.name,
            attr=t.attr, trigger=t.trigger,
            elem=t.elem,
            source=t.source,
        )

@api keypress => Keypress <: Behavior begin
    arg(keys::String)
    curry(tile::Tile)
    kwarg(name::Symbol=:_keys)
    kwarg(onpress::String="")
end

render(k::Keypress) =
    render(k.tile) & @d(:attributes => @d(:tabindex => 1)) <<
        Elem("keypress-behavior", keys=k.keys, name=k.name) &
            (k.onpress != "" ? @d(:onpress => k.onpress) : Dict())

immutable Key
    key::String
    alt::Bool
    ctrl::Bool
    meta::Bool
    shift::Bool
end

const nokey = Key("", false, false, false, false)

immutable KeyInterpreter <: Interpreter end

default_interpreter(k::Keypress) = KeyInterpreter()

interpret(::KeyInterpreter, d) =
    Key(d["key"], d["alt"], d["ctrl"], d["meta"], d["shift"])

abstract MouseButton

@terms MouseButton begin
    nobutton => NoButton
    leftbutton => LeftButton
    rightbutton => RightButton
    scrollbutton => ScrollButton
end

@api clickable => Clickable <: Behavior begin
    typedarg(buttons::AbstractArray=[leftbutton])
    curry(tile::Tile)
    kwarg(name::Symbol=:_clicks)
end

button_number(::LeftButton) = 1
button_number(::RightButton) = 2
button_number(::ScrollButton) = 3

immutable ClickInterpreter <: Interpreter
end

default_interpreter(c::Clickable) =
    ClickInterpreter()

interpret(c::ClickInterpreter, x) =
    try
        [leftbutton, rightbutton, scrollbutton][x]
    catch
        DomainError()
    end

render(c::Clickable) =
    render(c.tile) <<
        Elem("clickable-behavior";
            name=c.name,
            buttons=string(map(button_number, c.buttons)),
        )

@api selectable => Selectable <: Behavior begin
    curry(tile::Tile)
    kwarg(name::Symbol=:_clicks)
    kwarg(elem::String="::parent")
end

render(t::Selectable) =
    render(t.tile) <<
        Elem("selectable-behavior", name=t.name, elem=t.elem)

default_interpreter(t::Selectable) = ToType{Int}()

abstract MouseState

@terms MouseState begin
    mousedown => MouseDown
    mouseup => MouseUp
end

@api hoverable => Hoverable <: Behavior begin
    typedarg(get_coords::Bool=false)
    curry(tile::Tile)
    kwarg(name::Symbol=:_hover)
end

immutable Hover
    state::MouseState
    position::@compat Tuple{Float64, Float64}
end

immutable Editable <: Behavior
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
send(chan::Symbol, b::Behavior) =
    ChanSend(chan, b.name, b)

render(chan::ChanSend) =
    render(chan.tile) <<
        Elem("chan-send", chan=chan.chan, watch=chan.watch)


immutable ChanRecv <: Tile
    chan::Symbol
    attr::Symbol
    tile::Tile
end
recv(chan::Symbol, t, attr) =
    ChanRecv(chan, attr, t)

render(chan::ChanRecv) =
    render(chan.tile) <<
        Elem("chan-recv", chan=chan.chan, attr=chan.attr)


wire(a::Behavior, b, chan, attribute) =
    send(chan, a), recv(chan, b, attribute)
