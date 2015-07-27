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


@api hasstate => (WithState <: Behavior) begin
    doc("Watch for changes to an attribute/property.")
    curry(tile::Tile, doc="Tile to watch.")
    kwarg(name::Symbol=:_state, doc="A name to identify the behavior.")
    kwarg(
        attr::String="value",
        doc=md"""The attribute/property to watch. Note that this is the property
                 of the DOM node and not of the `Tile`."""
    )
    kwarg(
        elem::String="::parent",
        doc="A CSS selector for the element to watch."
        )
    kwarg(
        trigger::String="change",
        doc="The event that triggers a re-read of the attribute/property."
    )
    kwarg(
        source::String="",
        doc="""If set to "target", the attribute is read from the element firing
               the event."""
    )
end

default_interpreter(::WithState) = identity

render(t::WithState, state) =
    render(t.tile, state) <<
        Elem(
            "watch-state",
            name=t.name,
            attr=t.attr, trigger=t.trigger,
            elem=t.elem,
            source=t.source,
        )

@api keypress => (Keypress <: Behavior) begin
    doc("A keypress listener.")
    arg(
        keys::String,
        doc=md"""A space-separated list of keys. The grammar of valid keypress
                 specifiers is [here](https://www.polymer-project.org/0.5/components/core-a11y-keys/index.html)."""
    )
    curry(tile::Tile, doc="The tile to watch keypresses from.")
    kwarg(name::Symbol=:_keys, doc="Name to identify the behavior.")
    kwarg(onpress::String="", doc="For internal use.")
end

render(k::Keypress, state) =
    render(k.tile, state) & @d(:attributes => @d(:tabindex => 1)) <<
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

@api clickable => (Clickable <: Behavior) begin
    doc("Watch for clicks.")
    typedarg(
        buttons::AbstractArray=[leftbutton],
        doc=md"""An array of mouse buttons to watch. Valid values are
                 `leftbutton`, `rightbutton`, `scrollbutton`."""
    )
    curry(tile::Tile, doc="The tile to watch for clicks on.")
    kwarg(name::Symbol=:_clicks, doc="Name to identify the behavior.")
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

render(c::Clickable, state) =
    render(c.tile, state) <<
        Elem("clickable-behavior";
            name=c.name,
            buttons=string(map(button_number, c.buttons)),
        )

@api selectable => (Selectable <: Behavior) begin
    doc("Watch for a selection in a selection widget.")
    curry(tile::Tile, doc="A selection widget.")
    kwarg(name::Symbol=:_clicks, doc="The name to identify the behavior.")
    kwarg(elem::String="::parent", doc="For internal use.")
end

render(t::Selectable, state) =
    render(t.tile, state) <<
        Elem("selectable-behavior", name=t.name, elem=t.elem)

inc(x) = x+1
default_interpreter(t::Selectable) =
    Chained(InterpreterFn(inc), ToType{Int}())

abstract MouseState

@terms MouseState begin
    mousedown => MouseDown
    mouseup => MouseUp
end

@api hoverable => (Hoverable <: Behavior) begin
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

immutable ChanSend <: Behavior
    chan::Symbol
    watch::Symbol
    tile::Tile
end

# expose contained signal to outside
name(c::ChanSend) = c.watch
send(chan::Symbol, watch::Symbol, b) =
    ChanSend(chan, watch, broadcast(b))
send(chan::Symbol, b::Behavior) =
    ChanSend(chan, name(b), broadcast(b))

@apidoc send => (ChanSend <: Behavior) begin
    doc("Emit changes to an attribute/property to a named channel.")
    arg(chan::Symbol, doc="The name of the channel.")
    arg(watch::Symbol, doc="The attribute/property to watch.")
    arg(tile::Tile, doc="The tile to watch.")
end

render(chan::ChanSend, state) =
    render(chan.tile, state) <<
        Elem("chan-send", chan=chan.chan, watch=chan.watch)


immutable ChanRecv <: Tile
    chan::Symbol
    attr::Symbol
    tile::Tile
end
recv(chan::Symbol, t, attr) =
    ChanRecv(chan, attr, t)

@apidoc recv => (ChanSend <: Behavior) begin
    doc("Read values from a named channel.")
    arg(chan::Symbol, doc="The name of the channel.")
    arg(attr::Symbol, doc="The attribute/property to set.")
    arg(tile::Tile, doc="The tile to set the property of.")
end

render(chan::ChanRecv, state) =
    render(chan.tile, state) <<
        Elem("chan-recv", chan=chan.chan, attr=chan.attr)

wire(a, b, chan, attribute) =
    send(chan, a), recv(chan, b, attribute)

@apidoc wire => (ChanSend <: Behavior) begin
    doc("Connect attribute/property of two tiles over a named channel.")
    arg(a::Tile, doc="The sender tile.")
    arg(b::Tile, doc="The receiver tile.")
    arg(chan::Symbol, doc="The name of the channel.")
    arg(attr::Symbol, doc="The attribute/property to connect.")
end

