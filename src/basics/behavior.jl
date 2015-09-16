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
        attr::AbstractString="value",
        doc=md"""The attribute/property to watch. Note that this is the property
                 of the DOM node and not of the `Tile`."""
    )
    kwarg(
        selector::AbstractString="::parent",
        doc="A CSS selector for the element to watch."
        )
    kwarg(
        trigger::AbstractString="change",
        doc="The event that triggers a re-read of the attribute/property."
    )
end

default_interpreter(::WithState) = identity

render(t::WithState, state) =
    render(t.tile, state) <<
        Elem(
            "watch-state", attributes=@d(
                :name=>t.name,
                :attr=>t.attr,
                :trigger=>t.trigger,
                :selector=>t.selector,
            )
        )

@api keypress => (Keypress <: Behavior) begin
    doc("A keypress listener.")
    arg(
        keys::AbstractString,
        doc=md"""A space-separated list of keys. The grammar of valid keypress
                 specifiers is [here](https://www.polymer-project.org/0.5/components/core-a11y-keys/index.html)."""
    )
    curry(tile::Tile, doc="The tile to watch keypresses from.")
    kwarg(name::Symbol=:_keys, doc="Name to identify the behavior.")
end

render(k::Keypress, state) =
    render(k.tile, state) & @d(:attributes => @d(:tabindex => 0)) <<
        Elem("keypress-behavior", attributes = @d(:keys=>k.keys, :name=>k.name))

immutable Key
    key::AbstractString
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
            attributes=@d(
                :name=>c.name,
                :buttons=>string(map(button_number, c.buttons)),
            )
        )

@api selectable => (Selectable <: Behavior) begin
    doc("Watch for a selection in a selection widget.")
    curry(tile::Tile, doc="A selection widget.")
    kwarg(name::Symbol=:_clicks, doc="The name to identify the behavior.")
    kwarg(multi::Bool=false, doc="True when watching widgets that allow multiple selections")
    kwarg(selector::AbstractString="::parent", doc="CSS selector of the selectable widget.")
end

render(t::Selectable, state) =
    render(t.tile, state) <<
        Elem("selectable-behavior",
            attributes = @d(
                :name=>t.name,
		:multi=>boolattr( t.multi ),
                :selector=>t.selector
            )
        )

inc(x) = x+1
inc(x::AbstractArray) = map(inc, x)
default_interpreter(t::Selectable) = begin
    if t.multi
        InterpreterFn(inc) # FIXME: How do I ToType{Int} each element?
    else
        Chained(InterpreterFn(inc), ToType{Int}())
    end
end


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
    ChanSend(chan, watch, wrapbehavior(b))
send(chan::Symbol, b::Behavior) =
    ChanSend(chan, name(b), wrapbehavior(b))

@apidoc send => (ChanSend <: Behavior) begin
    doc("Emit changes to an attribute/property to a named channel.")
    arg(chan::Symbol, doc="The name of the channel.")
    arg(watch::Symbol, doc="The attribute/property to watch.")
    arg(tile::Tile, doc="The tile to watch.")
end

render(chan::ChanSend, state) =
    render(chan.tile, state) <<
        Elem("chan-send", attributes=@d(:chan=>chan.chan, :watch=>chan.watch))


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
        Elem("chan-recv", attributes = @d(:chan=>chan.chan, :attr=>chan.attr))

wire(a, b, chan, attribute) =
    send(chan, a), recv(chan, b, attribute)

@apidoc wire => (ChanSend <: Behavior) begin
    doc("Connect attribute/property of two tiles over a named channel.")
    arg(a::Tile, doc="The sender tile.")
    arg(b::Tile, doc="The receiver tile.")
    arg(chan::Symbol, doc="The name of the channel.")
    arg(attr::Symbol, doc="The attribute/property to connect.")
end
