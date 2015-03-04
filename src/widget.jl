import Base: |>
export bind,
       slider,
       checkbox,
       togglebutton,
       textinput,
       dropdown,
       labelfor

# A widget can signal some state
abstract Widget <: Tile

pipe(w::Widget, s::Input) = pipe(hasstate(w, name=w.name), s)
(|>)(w::Widget, s::Input) = pipe(w, s)

## Button

immutable Button <: Widget
end

pipe(w::Button, s::Input) = clickable(w) |> s

## Slider

immutable Slider{T <: Real} <: Widget
    name::Symbol
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
    Slider(name, convert(T, value), range, editable, pin, disabled, secondaryprogress)


## Boolean widgets: Checkbox and Toggle Button

immutable BoolWidget{typ} <: Widget
    name::Symbol
    value::Bool
    label::String
    disabled::Bool
end

checkbox(;
         name=:_checkbox,
         value=false,
         label="",
         disabled=false) =
    BoolWidget{:checkbox}(name, value, label, disabled)

togglebutton(;
             name=:_togglebutton,
             value=false,
             label="",
             disabled=false) =
    BoolWidget{:toggle}(name, value, label, disabled)

pipe(c::BoolWidget, x::Input) =
   hasstate(c, x, name=c.name, attr="checked", trigger="change")


## Text input

immutable TextInput <: Widget
    name::Symbol
    value::String
    label::String
    floatinglabel::Bool
    disabled::Bool
end

textinput(value::String="";
          name=:_textinput,
          label="",
          floatinglabel=false,
          disabled=false) =
    TextInput(name, value, label, floatinglabel, disabled)

pipe(t::TextInput, x::Input) =
   hasstate(t, x, attr="value", trigger="keyup")

## Dropdown

immutable SelectionItem{T} <: Tile
    value::T
    item::Tile
end

immutable Dropdown <: Widget
    name::Symbol
    value::String
    label::String
    items::Vector{SelectionItem}
    disabled::Bool
end

makeitems(xs) =
    [SelectionItem(k, v) for (k, v) in xs]

dropdown(items::AbstractArray;
         name=:_dropdown,
         value=first(items)) =
    Dropdown(name, makeitems(items), value)


# label a widget
immutable Label <: Widget
    target::Symbol
    label::Tile
end

