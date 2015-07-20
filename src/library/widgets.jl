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
       paper,
       datepicker

# A widget can be coerced into a behavior
# by calling `broadcast` on it.
abstract Widget <: Behavior

subscribe(w::Widget, x::Input; absorb=true) =
    subscribe(broadcast(w), x, absorb=absorb)

addinterpreter(i::Interpreter, w::Widget) =
    addinterpreter(i, broadcast(w))

default_interpreter(w::Widget) =
    default_interpreter(broadcast(w))

## Button

@api button => Button <: Widget begin
    arg(label::Tile)
    kwarg(name::Symbol=:_button)
    kwarg(raised::Bool=false)
    kwarg(disabled::Bool=false)
    kwarg(noink::Bool=false)
end

render(b::Button, state) =
    Elem("paper-button", render(b.label, state);
        attributes=@d(
            :raised => boolattr(b.raised, "raised"),
            :noink => boolattr(b.noink, "noink"),
            :disabled => boolattr(b.disabled, "disabled")
        )
    )

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
    addinterpreter(ToType{eltype(s.range)}(),
        hasstate(s, name=s.name))

render(s::Slider, state) =
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
            addinterpreter(ToType{Bool}(),
                hasstate(c, name=c.name, attr="checked", trigger="change"))

        render(c::$typ, state) =
            Elem($elem,
                checked=c.value,
                label=c.label,
                disabled=boolattr(c.disabled, "disabled"),
            )
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
    hasstate(t, name=t.name, attr="value", trigger=event, source="target") |>
        addinterpreter(ToType{String}())

render(t::TextInput, state) = begin
    if t.multiline
        if length(t.pattern) > 0
            warn_once(
                "Multi-line text input does not support pattern validation")
        end
        base = Elem("textarea", t.value;
            name=t.name,
            id=t.name,
        )

        if t.maxlength > 0
            base &= @d(:attributes => @d(:maxlength => t.maxlength))
        end
        if t.rows > 0
            base &= @d(:attributes => @d(:rows => t.rows))
        end
        elem = Elem("paper-input-decorator",
            Elem("paper-autogrow-textarea", base, maxRows=t.maxrows))
    else
        base = Elem("input",
            name=t.name,
            id=t.name,
            value=t.value,
            attributes=@d(:is => "core-input")
        )
        if t.pattern != ""
            base &= @d(:attributes => @d(:pattern => t.pattern))
        end
        if t.maxlength > 0
            base &= @d(:attributes => @d(:maxlength => t.maxlength))
        end
        elem = Elem("paper-input-decorator", base)
    end

    elem &= @d(:label => t.label,
             :error => t.error,
             :floatingLabel => t.floatinglabel,
             :autoValidate => t.autovalidate,
             :disabled => boolattr(t.disabled, "disabled"))

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

render(t::SelectionItem, state) =
    Elem("paper-item", render(t.tile, state), value=t.value)



## Radio buttons

@api radio => RadioButton <: Tile begin
    arg(name::Symbol)
    curry(label::String)
    kwarg(toggles::Bool=false)
    kwarg(disabled::Bool=false)
end

render(r::RadioButton, state) =
    Elem("paper-radio-button", label=r.label,
         name=r.name, toggles=r.toggles, disabled=r.disabled)

@api radiogroup => RadioGroup <: Widget begin
    arg(radios::AbstractArray)
    kwarg(name::Symbol=:_radiogroup)
    kwarg(value::Symbol=:_none)
end

wrapradio(x::RadioButton) = x
wrapradio(x) = begin
    name, label = x
    radio(name, label)
end

render(r::RadioGroup, state) =
    Elem("paper-radio-group",
        [render(wrapradio(b), state) for b in r.radios],
        value=r.value,
        name=r.name)

broadcast(r::RadioGroup) = selectable(r, name=r.name)

@api selector => Selector <: Widget begin
    arg(items::AbstractArray)
    kwarg(selected::Int=1)
end

## Spinner

@api spinner => Spinner <: Tile begin
    arg(active::Bool=true)
end

render(s::Spinner, state) = Elem("paper-spinner", active=s.active)

## Progress bar

@api progress => ProgressBar <: Tile begin
    arg(value::Real)
    kwarg(secondaryprogress::Real=0)
end

render(p::ProgressBar, state) =
    Elem("paper-progress";
        value=p.value,
        secondaryProgress=p.secondaryprogress,
    )

@api paper => PaperShadow <: Tile begin
    arg(z::Int)
    curry(tile::Tile)
    kwarg(animated::Bool=true)
end

render(p::PaperShadow, state) =
    Elem("paper-shadow", render(p.tile, state), z=p.z, animated=p.animated)

# Date picker

if VERSION < v"0.4.0-dev"
    using Dates
end


@api dateselection => DateSelection <: Behavior begin
    curry(tile::Tile)
    kwarg(name::Symbol=:_date)
end
render(d::DateSelection, state) =
    render(d.tile, state) << Elem("date-selection", name=d.name)

immutable DateInterpreter <: Interpreter end
default_interpreter(::DateSelection) = DateInterpreter()


@api datepicker => DatePicker <: Widget begin
    arg(date::Date=today())
    kwarg(range::Range{Date}=Date("1971-01-01"):Date("2100-12-31"))
    kwarg(name::Symbol=:_date)
end
render(d::DatePicker, state) =
    Elem("paper-date-picker-two", value=string(d.date), attributes=@d(:min=>string(first(d.range)), :max=>string(last(d.range))))
broadcast(p::DatePicker) = dateselection(p, name=p.name)

# TODO: Interpret as bounds error if date exceeds range
interpret(::DateInterpreter, d) = begin
    date = Date(d["year"], d["month"], d["day"])
end
