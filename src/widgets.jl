import Base: |>
export bind,
       slider,
       checkbox,
       togglebutton,
       textinput,
       dropdown,
       labelfor

include("nullable.jl")

# A widget
abstract Widget <: Tile

# A widget that can signal its state
abstract SignalWidget <: Tile

tag(w::SignalWidget) = w.tag

bind(w::SignalWidget, x::Input) = statesignal(w, x, tag=tag(w))
(|>)(w::SignalWidget, x::Input) = bind(w, x)


## Slider

immutable Slider{T <: Real} <: SignalWidget
    tag::Symbol
    value::T
    range::Range{T}
    editable::Bool
    pin::Bool
    disabled::Bool
    secondaryprogress::T
end

slider{T}(range::Range{T};
          tag=nexttag("slider"),
          value=first(range),
          editable=true,
          pin=false,
          disabled=false,
          secondaryprogress=zero(T)) =
    Slider(symbol(tag), convert(T, value), range, editable, pin, disabled, secondaryprogress)


## Boolean widgets: Checkbox and Toggle Button

immutable BoolWidget{typ} <: SignalWidget
    tag::Symbol
    value::Bool
    label::String
    disabled::Bool
end

checkbox(;
         tag=nexttag("checkbox"),
         value=false,
         label="",
         disabled=false) =
    BoolWidget{:checkbox}(symbol(tag), value, label, disabled)

togglebutton(;
             tag=nexttag("checkbox"),
             value=false,
             label="",
             disabled=false) =
    BoolWidget{:toggle}(symbol(tag), value, label, disabled)

bind(c::BoolWidget, x::Input) =
   statesignal(c, x, tag=tag(c), attr="checked", trigger="change")


## Text input

immutable TextInput <: SignalWidget
    tag::Symbol
    value::String
    label::String
    floatinglabel::Bool
    disabled::Bool
end

textinput(value::String=""; tag=nexttag("text"), floatinglabel=false, disabled=false) =
    TextInput(tag, value, label, floatinglabel, disabled)

bind(t::TextInput, x::Input) =
    statesignal(c, x)


## Dropdown

immutable SelectionItem{T} <: Tile
    key::T
    item::Tile
end

immutable Dropdown <: SignalWidget
    tag::Symbol
    value::String
    label::String
    items::Vector{SelectionItem}
end

makeitems(xs) =
    [SelectionItem(k, v) for (k, v) in xs]

dropdown(items::AbstractArray;
         tag=nexttag("dropdown"),
         value=first(items)) =
    Dropdown(makeitems(items), tag, value)


# label a widget
immutable Label <: Widget
    target::Symbol
    label::Tile
end

# FIXME
labelfor(w::Widget, tile) = Label(w.tag, tile)
labelfor(w, tile) = Label(symbol(w), tile)
