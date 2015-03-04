import Base: |>
export bind,
       button,
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
end

button(label; name=:_button) =
    clickable(Button(label), name=name)

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

togglebutton(;
             name=:_togglebutton,
             value=false,
             label="",
             disabled=false) =
    hasstate(
        BoolWidget{:toggle}(value, label, disabled),
        name=name, attr="checked", trigger="change")


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

## Dropdown

immutable SelectionItem{T} <: Tile
    value::T
    item::Tile
end

immutable Dropdown <: Widget
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
    hasstate(Dropdown(makeitems(items), value), name=name)


# label a widget
immutable Label <: Widget
    target::Symbol
    label::Tile
end

