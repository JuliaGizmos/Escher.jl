import Base: >>>
export broadcast,
       button,
       slider,
       checkbox,
       radio,
       radiogroup,
       togglebutton,
       textinput,
       progress,
       paper

# A widget can be coerced into a behavior
# by calling `broadcast` on it.
abstract Widget <: Tile

subscribe(w::Widget, x::Signal; absorb=true) =
    subscribe(broadcast(w), x, absorb=absorb)
(>>>)(w::Widget, x::Signal) = subscribe(w, x)

## Button

@api button => Button <: Widget begin
    arg(label::Tile)
    kwarg(name::Symbol=:_button)
    kwarg(raised::Bool=false)
    kwarg(disabled::Bool=false)
    kwarg(noink::Bool=false)
end

render(b::Button) =
    Elem("paper-button", render(b.label),
        attributes = [:raised => boolattr(b.raised, "raised"),
                      :noink => boolattr(b.noink, "noink"),
                      :disabled => boolattr(b.disabled, "disabled")])

broadcast(b::Button) =
    clickable(b, name=b.name)

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

broadcast(s::Slider) =
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
                        (:ToggleButton, :togglebutton, "paper-toggle-button")]

    @eval begin
        @api $fn => $typ <: Widget begin
            arg(value::Bool=false)
            kwarg(name::Symbol=:_checkbox)
            kwarg(label::String="")
            kwarg(disabled::Bool=false)
        end

        broadcast(c::$typ) =
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
    kwarg(format::String="")
    kwarg(error::String="")
    kwarg(floatinglabel::Bool=true)
    kwarg(multiline::Bool=false)
    kwarg(rows::Int=0)
    kwarg(maxrows::Int=0)
    kwarg(maxlength::Int=0)
    kwarg(charcounter::Bool=false)
    kwarg(pattern::String="")
    kwarg(autovalidate::Bool=true)
    kwarg(disabled::Bool=false)
end

broadcast(t::TextInput, event="input") =
    hasstate(t, name=t.name, attr="value", trigger=event, source="target")

render(t::TextInput) = begin
    if t.multiline
        if length(t.pattern) > 0
            warn_once("Multi-line text input does not support pattern validation")
        end
        base = Elem("textarea", t.value,
            name=t.name,
            id=t.name,
        )

        if t.maxlength > 0
            base &= [:attributes => [:maxlength => t.maxlength]]
        end
        if t.rows > 0
            base &= [:attributes => [:rows => t.rows]]
        end
        elem = Elem("paper-input-decorator",
            Elem("paper-autogrow-textarea", base, maxRows=t.maxrows))
    else
        base = Elem("input",
            name=t.name,
            id=t.name,
            value=t.value,
            attributes=[:is => "core-input"]
        )
        if t.pattern != ""
            base &= [:attributes => [:pattern => t.pattern]]
        end
        if t.maxlength > 0
            base &= [:attributes => [:maxlength => t.maxlength]]
        end
        elem = Elem("paper-input-decorator", base)
    end

    elem &= [:label => t.label,
             :error => t.error,
             :floatingLabel => t.floatinglabel,
             :autoValidate => t.autovalidate,
             :disabled => boolattr(t.disabled, "disabled")]

    if t.charcounter
        elem <<= Elem("polymer-char-counter", target=t.name)
    end

    elem
end

## Dropdown

@api selectionitem => SelectionItem <: Tile begin
    arg(value::Any)
    curry(item::Tile)
end

render(t::SelectionItem) =
    Elem("paper-item", render(t.tile), value=t.value)



## Radio buttons

@api radio => RadioButton <: Tile begin
    arg(name::Symbol)
    curry(label::String)
    kwarg(toggles::Bool=false)
    kwarg(disabled::Bool=false)
end

render(r::RadioButton) =
    Elem("paper-radio-button", label=r.label,
         name=r.name, toggles=r.toggles, disabled=r.disabled)

@api radiogroup => RadioGroup <: Widget begin
    arg(radios::Any)
    kwarg(name::Symbol=:_radiogroup)
    kwarg(value::Symbol=:_none)
end

wrapradio(x::RadioButton) = x
wrapradio(x) = begin
    name, label = x
    radio(name, label)
end

render(r::RadioGroup) =
    Elem("paper-radio-group",
        [render(wrapradio(b)) for b in r.radios],
        value=r.value,
        name=r.name)

broadcast(r::RadioGroup) = selectable(r, name=r.name)

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
