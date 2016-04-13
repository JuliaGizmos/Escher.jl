import Base: >>>
export wrapbehavior,
       button,
       slider,
       checkbox,
       radio,
       radiogroup,
       togglebutton,
       textinput,
       progress,
       spinner,
       paper,
       datepicker

# A widget can be coerced into a behavior
# by calling `wrapbehavior` on it.
abstract Widget <: Behavior

subscribe(x::Signal, w::Widget) =
    subscribe(x, wrapbehavior(w))

# Ambiguity
intent(c::Union{Sampler, Collector}, tile::Widget) =
    OuterListener(c, tile)

intent(i::Intent, w::Widget) =
    intent(i, wrapbehavior(w))

default_intent(w::Widget) =
    default_intent(wrapbehavior(w))

## Button

@api button => (Button <: Widget) begin
    doc("A button.")
    arg(label::Tile, doc="The button label.")
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
            :raised => boolattr(b.raised),
            :noink => boolattr(b.noink),
            :disabled => boolattr(b.disabled)
        )
    )

wrapbehavior(b::Button) =
    clickable(b)

## Slider

@api slider => (Slider <: Widget) begin
    doc("""A slider. Use this to select values from within a continous range of
           numbers.""")
    arg(
        range::Range,
        doc="""The range specifying the minimum and maximum values that the slider
             can take."""
    )
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

wrapbehavior(s::Slider) =
    intent(ToType{eltype(s.range)}(), hasstate(s))

render(s::Slider, state) =
    Elem("paper-slider", attributes=@d(
        :min => first(s.range),
        :max => last(s.range),
        :step => step(s.range),
        :value => s.value,
        :editable => boolattr(s.editable),
        :pin => boolattr(s.pin),
        :disabled => boolattr(s.disabled),
        :secondaryProgress => s.secondaryprogress,
        )
    )


## Checkbox
@api checkbox => (Checkbox <: Widget) begin
    doc("A checkbox.")
    arg(value::Bool=false, doc="State of the checkbox.")
    arg(label::Tile="", doc="The label.")
    kwarg(
        disabled::Bool=false,
        doc="If set to true, the checkbox will be disabled."
    )
end

wrapbehavior(c::Checkbox) =
    intent(ToType{Bool}(),
        hasstate(c, attr="checked", trigger="change"))

render(c::Checkbox, state) =
    Elem("paper-checkbox",
        render(c.label, state),
        attributes = @d(
            :checked=>boolattr(c.value),
            :disabled=>boolattr(c.disabled),
        )
    )

## Toggle Button
@api togglebutton => (ToggleButton <: Widget) begin
    doc("A toggle button.")
    arg(value::Bool=false, doc="State of the toggle button.")
    kwarg(
        disabled::Bool=false,
        doc="If set to true, the toggle button will be disabled."
    )
    kwarg(
        toggles::Bool=true,
        doc="If set to false, the user will not be able to change the state."
    )
end

wrapbehavior(c::ToggleButton) =
    intent(ToType{Bool}(),
        hasstate(c, attr="checked", trigger="change"))

render(c::ToggleButton, state) =
    Elem("paper-toggle-button",
        attributes = @d(
            :checked=>boolattr(c.value),
            :disabled=>boolattr(c.disabled),
            :toggles=>boolattr(c.disabled),
        )
    )

## Text input

@api textinput => (TextInput <: Widget) begin
    doc("A text input box.")
    arg(value::AbstractString="", doc="The current content.")
    kwarg(label::AbstractString="", doc="The label.")
    kwarg(error::AbstractString="", doc="Error to display if invalid input is entered.")
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
        will expand to. More lines will make the text input scrollable. (no limit if set to 0)""")
    kwarg(maxlength::Int=0, doc="Set the maximum length of input text.")
    kwarg(minlength::Int=0, doc="Set the minimum length of input text (not available in multiline).")
    kwarg(
        charcounter::Bool=false,
        doc="If set to true, a character count is displayed below the input field."
    )
    kwarg(
        pattern::AbstractString="",
        doc=md"""Pattern of allowed inputs. The pattern must match the entire value,
              not just some subset. The regular expression language is the same
              as [JavaScript's]
              (https://developer.mozilla.org/en/docs/Web/JavaScript/Guide/Regular_Expressions)
              (not available in multiline mode)
              ."""
    )
    #kwarg(autovalidate::Bool=true, doc="")
    kwarg(
        disabled::Bool=false,
        doc="If set to true, the text input will be disabled."
    )
end

wrapbehavior(t::TextInput, event="input") =
    hasstate(t, attr="value", trigger=event) |>
        intent(ToType{AbstractString}())

render(t::TextInput, state) = begin
    if t.multiline
        if length(t.pattern) > 0
            warn(
                "Multi-line text input does not support pattern validation")
        end

        elem = Elem("paper-textarea")

        if t.rows > 0
            elem &= @d(:attributes => @d(:rows => t.rows))
        end

        if t.maxrows > 0
            elem &= @d(:attributes => @d(:maxRows => t.maxrows))
        end
    else

        elem = Elem("paper-input")
        if t.pattern != ""
            elem &= @d(:attributes => @d("pattern" => t.pattern))
        end
    end

    if t.maxlength > 0
        elem &= @d(:attributes => @d(:maxlength => t.maxlength))
    end

    if t.minlength > 0
        elem &= @d(:attributes => @d(:minlength => t.minlength))
    end

    elem & @d(:attributes => @d(
                 "value" => t.value,
                 "label" => t.label,
                 "error-message" => t.error,
                 "auto-validate" => boolattr(true),
                 "disabled" => boolattr(t.disabled),
                 "char-counter" => boolattr(t.charcounter),
                 "no-label-float" => boolattr(!t.floatinglabel),
                 )
             )
end

## Radio buttons

@api radio => (RadioButton <: Tile) begin
    doc(md"""A radio button. Usually many radio buttons are grouped in a
    `radio group`.""")
    arg(
        name::AbstractString,
        doc=md"A name. The output of a `radiogroup` is the name of the selected radio button."
    )
    curry(label::Tile, doc="The label.")
    kwarg(
        value::Bool=false,
        doc="Is this radio button selected. When using in a radiogroup set `selected` field in the group instead."
    )
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
    Elem("paper-radio-button",
        render(r.label, state),
        attributes=@d(
            :name=>r.name,
            :checked=>boolattr(r.value),
            :toggles=>boolattr(r.toggles),
            :disabled=>boolattr(r.disabled)
        )
    )

@api radiogroup => (RadioGroup <: Widget) begin
    doc("""A group of radio buttons. At any time, only one radio button in a group
    can be selected.""")
    arg(radios::AbstractArray, doc="A vector of radio buttons.")
    kwarg(selected::AbstractString="", doc=md"Name of the currently selected `radiobutton`")
end

wrapradio(x::RadioButton) = x
wrapradio(x) = begin
    radio(string(x), x)
end

render(r::RadioGroup, state) =
    Elem("paper-radio-group",
        [render(wrapradio(b), state) for b in r.radios],
        attributes=@d(
            :selected=>r.selected,
        )
    )

wrapbehavior(r::RadioGroup) =
    hasstate(r, attr="selected", trigger="paper-radio-group-changed") |>
        intent(ToType{AbstractString}())


@api selector => (Selector <: Widget) begin
    arg(items::AbstractArray)
    kwarg(selected::Int=1)
end

## Spinner

@api spinner => (Spinner <: Tile) begin
    doc("A spinner. Usually used to denote something is loading or underway.")
    arg(active::Bool=true, doc="If set to false, the spinner will disappear.")
end

render(s::Spinner, state) =
    Elem("paper-spinner", attributes=@d(:active=>boolattr(s.active)))

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
        attributes = @d(
            "value"=>p.value,
            "secondary-progress"=>p.secondaryprogress,
        )
    )

@api paper => (PaperShadow <: Tile) begin
    doc("Raise a tile above the plane of the page and create a realistic shadow.")
    arg(elevation::Int, doc="The level to raise to. Valid values are Integers 1 to 5.")
    curry(tile::Tile, doc="The tile to be raised.")
    kwarg(
        animated::Bool=true,
        doc=md"If set to true, changes to `z` will be animated."
    )
end

render(p::PaperShadow, state) =
    Elem("paper-material", render(p.tile, state),
        attributes=@d(:elevation=>p.elevation, :animated=>p.animated))

# Date picker

# TODO: Migrate date picker to Polymer 1.0

if VERSION < v"0.4.0-dev"
    using Dates
end


@api dateselection => (DateSelection <: Behavior) begin
    arg(tile::Tile)
end
render(d::DateSelection, state) =
    render(d.tile, state) << Elem("date-selection")

immutable DateIntent <: Intent end
default_intent(::DateSelection) = DateIntent()


@api datepicker => (DatePicker <: Widget) begin
    doc("A date picker.")
    arg(date::Date=today(), doc=md"The date. Requires the `Dates` module on Julia v0.3")
    kwarg(
        range::Range{Date}=Date("1971-01-01"):Date("2100-12-31"),
        doc="The range of selectable dates."
    )
end
render(d::DatePicker, state) =
    Elem(
        "paper-date-picker-two",
        value=string(d.date),
        attributes=@d(:min=>string(first(d.range)), :max=>string(last(d.range)))
    )
wrapbehavior(p::DatePicker) = dateselection(p)

# TODO: Interpret as bounds error if date exceeds range
interpret(::DateIntent, d) = begin
    Date(d["year"], d["month"], d["day"])
end
