import Base: >>>
export watch,
       button,
       slider,
       checkbox,
       radio,
       radiogroup,
       togglebutton,
       textinput,
       dropdown,
       progress,
       paper

# A widget can signal some state
abstract Widget <: Tile

(>>>)(w::Widget, x::Signal) = watch(w) >>> x

## Button

@api button => Button <: Widget begin
    arg(label::Tile)
    kwarg(raised::Bool)
    kwarg(noink::Bool)
end

render(b::Button) =
    Elem("paper-button", render(b.label),
        raised=boolattr(b.raised, "raised"), noink=boolattr(b.raised, "raised"))


## Slider

@api slider => Slider <: Widget begin
    arg(range::Range)
    kwarg(name::Symbol=:_slider)
    kwarg(value::Real=first(range))
    kwarg(editable::Bool=true)
    kwarg(pin::Bool=false)
    kwarg(disabled::Bool=false)
    kwarg(secondaryprogress::Real=0)
end

watch(s::Slider) =
    hasstate(s, name=s.name)

render(s::Slider) =
    Elem("paper-slider",
        min=first(s.range),
        max=last(s.range),
        step=step(s.range),
        value=s.value,
        editable=s.editable,
        pin=s.pin,
        disabled=s.disabled,
        secondaryProgress=s.secondaryprogress)


## Boolean widgets: Checkbox and Toggle Button

for (typ, fn, elem) in [(:Checkbox, :checkbox, "paper-checkbox"),
                        (:ToggleButton, :togglebutton, "toggle-button")]

    @eval begin
        @api $fn => $typ <: Widget begin
            arg(value::Bool=false)
            kwarg(name::Symbol=:_checkbox)
            kwarg(label::String="")
            kwarg(disabled::Bool=false)
        end

        watch(c::$typ) =
            hasstate(c, name=c.name, attr="checked", trigger="change")

        render(c::$typ) =
            Elem($elem,
                checked=c.value,
                disabled=boolattr(c.disabled, "disabled"))
    end
end

## Text input

@api textinput => TextInput <: Widget begin
    arg(value::String="")
    kwarg(name::Symbol=:_textinput)
    kwarg(label::String="")
    kwarg(floatinglabel::Bool=true)
    kwarg(disabled::Bool=false)
end

watch(t::TextInput, event="keyup") =
    hasstate(t, name=t.name, attr="value", trigger=event)

render(t::TextInput) =
    Elem("paper-input",
        label=t.label,
        name=t.name,
        value=t.value,
        floatingLabel=boolattr(t.floatinglabel, "floatingLabel"),
        disabled=boolattr(t.disabled, "disabled"))

@api textarea => TextArea <: Widget begin
    arg(value::String="")
    kwarg(rows::Int=1)
    kwarg(maxrows::Int=0)
end

render(t::TextArea) =
    Elem("paper-autogrow-textarea", rows=t.rows, maxRows=t.maxrows)

watch(t::TextArea, event="keyup") =
    hasstate(t, name=t.name, attr="value", trigger=event)

## Dropdown

@api selectionitem => SelectionItem <: Tile begin
    arg(value::Any)
    curry(item::Tile)
end

render(t::SelectionItem) =
    Elem("paper-item", render(t.tile), value=t.value)


@api dropdown => Dropdown <: Widget begin
    arg(items::AbstractArray)
    kwarg(value::Int=0)
    kwarg(label::String)
    kwarg(disabled::Bool=false)
end

wrapitem(x::SelectionItem) = x
wrapitem(x) = Elem("paper-item", render(x))

render(d::Dropdown) =
    Elem("paper-dropdown-menu",
        map(x -> render(wrapitem(x)), d.items),
        value=d.value,
        name=d.name,
        label=d.label,
        floatingLabel=boolattr(d.floatinglabel, "floatingLabel"),
        disabled=boolattr(d.disabled, "disabled"))

watch(d::Dropdown) = hasstate(d, name=d.name)


## Radio buttons

@api radio => RadioButton <: Tile begin
    arg(name::Symbol)
    curry(label::String)
    kwarg(toggles::Bool=false)
    kwarg(disabled::Bool=false)
end

render(r::RadioButton) =
    Elem("paper-radio", label=r.label,
         name=r.name, toggles=r.toggles, disabled=r.disabled)

@api radiogroup => RadioGroup <: Widget begin
    arg(radios::Any)
    kwarg(name::Symbol=:_radiogroup)
    kwarg(value::Symbol=:_none)
end

wrapradio(x::RadioButton) = x
function wrapradio(x)
    name, label = x
    radio(name, label)
end

render(r::RadioGroup) =
    Elem("paper-radio-group",
        [render(wrapradio(b)) for b in r.radios],
        value=r.value,
        name=r.name)

watch(r::RadioGroup) = selectable(r, name=r.name)

## Spinner

@api spinner => Spinner begin
    arg(active::Bool=true)
end

render(s::Spinner) = Elem("paper-spinner", active=s.active)

## Progress bar

@api progress => ProgressBar begin
    arg(value::Real)
    kwarg(secondaryprogress::Real=0)
end

render(p::ProgressBar) = Elem("paper-progress",
                              value=p.value,
                              secondaryProgress=p.secondaryprogress)

@api paper => PaperShadow <: Tile begin
    arg(z::Int)
    curry(tile::Tile)
    kwarg(animated::Bool=true)
end

render(p::PaperShadow) = Elem("paper-shadow", render(p.tile), z=p.z, animated=p.animated)
