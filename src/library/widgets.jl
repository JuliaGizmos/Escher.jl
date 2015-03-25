import Base: |>
export button,
       slider,
       checkbox,
       togglebutton,
       textinput,
       dropdown,
       labelfor

# A widget can signal some state
abstract Widget <: Tile

## Button

immutable Button <: Widget
    label::Tile
    raised::Bool
    noink::Bool
end

button(label; name=:_button, raised=false, noink=false) =
    clickable(Button(label, raised, noink), name=name)

render(b::Button) =
    Elem("paper-button", render(b.label),
        raised=boolattr(b.raised, "raised"), noink=boolattr(b.raised, "raised"))


## Slider

immutable Slider{T <: Real} <: Widget
    value::T
    range::Range{T}
    editable::Bool
    pin::Bool
    disabled::Bool
    secondaryprogress::T
end

slider{T}(range::Range{T};
          name=:_slider,
          value=first(range),
          editable=true,
          pin=false,
          disabled=false,
          secondaryprogress=zero(T)) =
    hasstate(
        Slider(convert(T, value), range, editable, pin, disabled, secondaryprogress),
        name=name)

render(s::Slider) =
    Elem("paper-slider",
        min=first(s.range),
        max=last(s.range),
        step=step(s.range),
        value=s.value,
        editable=s.editable,
        disabled=s.disabled,
        secondaryProgress=s.secondaryprogress)



## Boolean widgets: Checkbox and Toggle Button

immutable BoolWidget{typ} <: Widget
    value::Bool
    label::String
    disabled::Bool
end

checkbox(;
         name=:_checkbox,
         value=false,
         label="",
         disabled=false) =
    hasstate(
        BoolWidget{:checkbox}(value, label, disabled),
        name=name, attr="checked", trigger="change")

render(c::BoolWidget{:checkbox}) =
    Elem("paper-checkbox",
        checked=c.value,
        disabled=boolattr(c.disabled, "disabled"))


togglebutton(;
             name=:_togglebutton,
             value=false,
             label="",
             disabled=false) =
    hasstate(
        BoolWidget{:toggle}(value, label, disabled),
        name=name, attr="checked", trigger="change")

render(t::BoolWidget{:toggle}) =
    Elem("paper-toggle-button",
        checked=t.value,
        disabled=boolattr(t.disabled, "disabled"))


## Text input

immutable TextInput <: Widget
    value::String
    label::String
    floatinglabel::Bool
    disabled::Bool
end

textinput(value::String="";
          label="",
          name=:_textinput,
          floatinglabel=false,
          disabled=false) =
    hasstate(
        TextInput(value, label, floatinglabel, disabled),
        name=name, attr="value", trigger="keyup")

render(t::TextInput) =
    Elem("paper-input",
        label=t.label,
        value=t.value,
        floatingLabel=boolattr(t.floatinglabel, "floatingLabel"),
        disabled=boolattr(t.disabled, "disabled"))

## Dropdown

immutable SelectionItem{T} <: Tile
    value::T
    item::Tile
end

render(t::SelectionItem) =
    Elem("paper-item", render(t.tile), value=t.value)


immutable Dropdown <: Widget
    value::String
    label::String
    items::Vector{SelectionItem}
    disabled::Bool
end

render(d::Dropdown) =
    Elem("paper-dropdown-menu",
        value=d.value,
        label=d.label,
        floatingLabel=boolattr(d.floatinglabel, "floatingLabel"),
        disabled=boolattr(d.disabled, "disabled")) |>
    (wrap -> reduce(<<, wrap, map(render, d.items)))


## TODO: Look into this stuff again!
makeitems(xs) =
    [SelectionItem(k, v) for (k, v) in xs]

dropdown(items::AbstractArray;
         name=:_dropdown,
         value=first(items)) =
    hasstate(Dropdown(makeitems(items), value), name=name)


# label a widget
immutable Label <: Widget
    target::Symbol
    label::Tile
end

