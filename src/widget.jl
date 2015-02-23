import Base: |>
export bind,
       slider,
       checkbox,
       togglebutton,
       textinput,
       dropdown,
       labelfor

# A widget
abstract Widget <: Tile

# A widget that can signal its state
abstract SignalWidget <: Tile

bind(w::SignalWidget, x::Input) = hasstate(w, x)
(|>)(w::SignalWidget, x::Input) = bind(w, x)


## Slider

immutable Slider{T <: Real} <: SignalWidget
    value::T
    range::Range{T}
    editable::Bool
    pin::Bool
    disabled::Bool
    secondaryprogress::T
end

slider{T}(range::Range{T};
          value=first(range),
          editable=true,
          pin=false,
          disabled=false,
          secondaryprogress=zero(T)) =
    Slider(convert(T, value), range, editable, pin, disabled, secondaryprogress)


## Boolean widgets: Checkbox and Toggle Button

immutable BoolWidget{typ} <: SignalWidget
    value::Bool
    label::String
    disabled::Bool
end

checkbox(;
         value=false,
         label="",
         disabled=false) =
    BoolWidget{:checkbox}(value, label, disabled)

togglebutton(;
             value=false,
             label="",
             disabled=false) =
    BoolWidget{:toggle}(value, label, disabled)

bind(c::BoolWidget, x::Input) =
   hasstate(c, x, attr="checked", trigger="change")


## Text input

immutable TextInput <: SignalWidget
    value::String
    label::String
    floatinglabel::Bool
    disabled::Bool
end

textinput(value::String="";
          label="",
          floatinglabel=false,
          disabled=false) =
    TextInput(value, label, floatinglabel, disabled)

bind(t::TextInput, x::Input) =
   hasstate(t, x, attr="value", trigger="keyup")

## Dropdown

immutable SelectionItem{T} <: Tile
    value::T
    item::Tile
end

immutable Dropdown <: SignalWidget
    value::String
    label::String
    items::Vector{SelectionItem}
    disabled::Bool
end

makeitems(xs) =
    [SelectionItem(k, v) for (k, v) in xs]

dropdown(items::AbstractArray;
         value=first(items)) =
    Dropdown(makeitems(items), value)


# label a widget
immutable Label <: Widget
    target::Symbol
    label::Tile
end

