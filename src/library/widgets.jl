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

@api button => (Button <: Widget) begin
    doc("A button.")
    arg(label::Tile, doc="The button label.")
    kwarg(name::Symbol=:_button, doc="A name to identify the widget.")
    kwarg(
        raised::Bool=false,
        doc="If set to true, the button appears raised from the plane of the page."
    )
    kwarg(
        disabled::Bool=false,
        doc="If set to true, the button is disabled and will not be clickable."
    ) 
    kwarg(
        noink::Bool=false,
        doc="If set to true, disables the ripple effect when clicked."
    )
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

@api slider => (Slider <: Widget) begin
    doc("""A slider. Use this to select values from within a continous range of
           numbers.""")
    arg(
        range::Range,
        doc="""The range specifying the minimum and maximum values that the slider
             can take."""
    )
    kwarg(name::Symbol=:_slider, doc="A name to identify the widget")
    kwarg(
        value::Real=first(range),
        doc="The initial value of the slider. Defaults to the first value in the range."
    )
    kwarg(
        editable::Bool=true,
        doc="""If set to true, shows an editable text box with the current value
        of the slider."""
    )
    kwarg(
        pin::Bool=false,
        doc="""If set to true, shows a pin containing the current value as you
        drag the slider."""
    )
    kwarg(disabled::Bool=false, doc="If set to true, the slider is disabled.")
    kwarg(
        secondaryprogress::Real=0,
        doc="Highlight the slider bar from the beginning to this value."
    )
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


## Checkbox 
@api checkbox => (Checkbox <: Widget) begin
    doc("A checkbox.")
    arg(value::Bool=false, doc="State of the checkbox.")
    kwarg(name::Symbol=:_checkbox,doc="Name to identify the widget.")
    kwarg(label::String="", doc="The label.") #FIXME: Does this work?
    kwarg(
        disabled::Bool=false,
        doc="If set to true, the checkbox will be disabled."
    )
end

broadcast(c::Checkbox) =
    addinterpreter(ToType{Bool}(),
        hasstate(c, name=c.name, attr="checked", trigger="change"))

render(c::Checkbox, state) =
    Elem("paper-checkbox",
        checked=c.value,
        label=c.label,
        disabled=boolattr(c.disabled, "disabled"),
    )

## Toggle Button
@api togglebutton => (ToggleButton <: Widget) begin
    doc("A toggle button.")
    arg(value::Bool=false, doc="State of the toggle button.")
    kwarg(name::Symbol=:_togglebutton, doc="Name to identify the widget.")
    kwarg(label::String="", doc="The label.") #FIXME: Does this work?
    kwarg(
        disabled::Bool=false,
        doc="If set to true, the toggle button will be disabled."
    )
end

broadcast(c::ToggleButton) =
    addinterpreter(ToType{Bool}(),
        hasstate(c, name=c.name, attr="checked", trigger="change"))

render(c::ToggleButton, state) =
    Elem("paper-toggle-button",
        checked=c.value,
        label=c.label,
        disabled=boolattr(c.disabled, "disabled"),
    )

## Text input

@api textinput => (TextInput <: Widget) begin
    doc("A text input box.")
    arg(value::String="", doc="The current content.")
    kwarg(name::Symbol=:_textinput, doc="Name to identify the widget.")
    kwarg(label::String="", doc="The label.")
    kwarg(error::String="", doc="Error to display if invalid input is entered.")
    kwarg(
        floatinglabel::Bool=true,
        doc="If set to true, the label floats above the input field when the
        input field is non-empty."
    )
    kwarg(
        multiline::Bool=false,
        doc="If set to true, input can contain new lines."
    )
    kwarg(rows::Int=0, doc="(Only in multiline mode). Number of rows of text.")
    kwarg(
        maxrows::Int=0,
        doc="""(Only in multiline mode). Maximum number of rows the input field
        will expand to. More lines will make the text input scrollable.""")
    kwarg(maxlength::Int=0, doc="Set the maximum length of input text.")
    kwarg(
        charcounter::Bool=false,
        doc="If set to true, a character count is displayed below the input field."
    )
    kwarg(
        pattern::String="",
        doc=md"""Pattern of allowed inputs. The pattern must match the entire value,
              not just some subset. The regular expression language is the same
              as [JavaScript's]
              (https://developer.mozilla.org/en/docs/Web/JavaScript/Guide/Regular_Expressions)
              ."""
    )
    #kwarg(autovalidate::Bool=true, doc="")
    kwarg(
        disabled::Bool=false,
        doc="If set to true, the text input will be disabled."
    )
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
             :autoValidate => true,
             :disabled => boolattr(t.disabled, "disabled"))

    if t.charcounter
        elem <<= Elem("polymer-char-counter", target=t.name)
    end

    elem
end

@api selectionitem => (SelectionItem <: Tile) begin
    arg(value::Any)
    curry(item::Tile)
end

render(t::SelectionItem, state) =
    Elem("paper-item", render(t.tile, state), value=t.value)

## Radio buttons

@api radio => (RadioButton <: Tile) begin
    doc(md"""A radio button. Usually many radio buttons are grouped in a
    `radio group`.""")
    arg(name::Symbol, doc="Name to identify the widget.")
    curry(label::String, doc="The label.")
    kwarg(
        toggles::Bool=false,
        doc="If set to true, the radio button allows de-selection by clicking again."
    )
    kwarg(
        disabled::Bool=false,
        doc="If set to true, the radio button will be disabled."
    )
end

render(r::RadioButton, state) =
    Elem("paper-radio-button", label=r.label,
         name=r.name, toggles=r.toggles, disabled=r.disabled)

@api radiogroup => (RadioGroup <: Widget) begin
    doc("""A group of radio buttons. At any time, only one radio button in a group
    can be selected.""")
    arg(radios::AbstractArray, doc="A vector of radio buttons.")
    kwarg(name::Symbol=:_radiogroup, doc="Name to identify the widget.")
    kwarg(value::Symbol=:_none, doc="Currently selected value.") #FIXME: Check if this is correct.
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

@api selector => (Selector <: Widget) begin
    arg(items::AbstractArray)
    kwarg(selected::Int=1)
end

## Spinner

@api spinner => (Spinner <: Tile) begin
    doc("A spinner. Usually used to denote something is loading or underway.")
    arg(active::Bool=true, doc="If set to false, the spinner will disappear.")
end

render(s::Spinner, state) = Elem("paper-spinner", active=s.active)

## Progress bar

@api progress => (ProgressBar <: Tile) begin
    doc("A progress bar.")
    arg(value::Real, doc="Current primary progress.")
    kwarg(
        secondaryprogress::Real=0,
        doc="The secondary progress displayed in a lighter color."
    )
end

render(p::ProgressBar, state) =
    Elem("paper-progress";
        value=p.value,
        secondaryProgress=p.secondaryprogress,
    )

@api paper => (PaperShadow <: Tile) begin
    doc("Raise a tile above the plane of the page and create a realistic shadow.")
    arg(z::Int, doc="The level to raise to. Valid values are Integers 1 to 5.")
    curry(tile::Tile, doc="The tile to be raised.")
    kwarg(
        animated::Bool=true,
        doc=md"If set to true, changes to `z` will be animated."
    ) #FIXME: Does this work?
end

render(p::PaperShadow, state) =
    Elem("paper-shadow", render(p.tile, state), z=p.z, animated=p.animated)

# Date picker

if VERSION < v"0.4.0-dev"
    using Dates
end


@api dateselection => (DateSelection <: Behavior) begin
    curry(tile::Tile)
    kwarg(name::Symbol=:_date)
end
render(d::DateSelection, state) =
    render(d.tile, state) << Elem("date-selection", name=d.name)

immutable DateInterpreter <: Interpreter end
default_interpreter(::DateSelection) = DateInterpreter()


@api datepicker => (DatePicker <: Widget) begin
    doc("A date picker.")
    arg(date::Date=today(), doc=md"The date. Requires the `Dates` module on Julia v0.3")
    kwarg(
        range::Range{Date}=Date("1971-01-01"):Date("2100-12-31"),
        doc="The range of selectable dates."
    )
    kwarg(name::Symbol=:_date, doc="Name to identify the widget.")
end
render(d::DatePicker, state) =
    Elem(
        "paper-date-picker-two", 
        value=string(d.date), 
        attributes=@d(:min=>string(first(d.range)), :max=>string(last(d.range)))
    )
broadcast(p::DatePicker) = dateselection(p, name=p.name)

# TODO: Interpret as bounds error if date exceeds range
interpret(::DateInterpreter, d) = begin
    date = Date(d["year"], d["month"], d["day"])
end
