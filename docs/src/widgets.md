# Widgets

Widgets are graphical elements that can take all sorts of input from the user, and update their `Observable` as soon as they receive such input. To access the `Observable` each widget uses to store its value, use `observe(widget)`.

Widgets can be broadly categorized depending on the input they take:

- [Text input](@ref) widgets take a string that's typed in by the user and can represent either a Julia string or a number.
- [Type input](@ref) widgets take inputs that correspond to non-text Julia types (`Color`, `Date`, `Time` and `Bool`)
- [File input](@ref) widget is a file selector
- [Range input](@ref) widget is used to select a value within a range (via a slider)
- [Callback input](@ref) widget is used to have a callback event, the actual value of the `Observable` is not relevant
- [HTML5 input](@ref) is a way to access directly the HTML `<input>` tag, should only be relevant for advanced use
- [Option input](@ref) is used to choose between options

## Text input

These are widgets to select text input that's typed in by the user. For numbers use [`spinbox`](@ref) and for strings use [`textbox`](@ref). String entries ([`textbox`](@ref) and [`autocomplete`](@ref)) are initialized as `""`, whereas [`spinbox`](@ref) defaults to `nothing`, which corresponds to the empty entry.

```@docs
spinbox
textbox
autocomplete
```

## Type input

These are widgets to select a specific, non-text, type of input. So far, `Date`, `Time`, `Color` and `Bool` are supported. Types that allow a empty field (`Date` and `Time`) are initialized as `nothing` by default, whereas `Color` and `Bool` are initialized with the default HTML value (`colorant"black"` and `false` respectively).

```@docs
datepicker
timepicker
colorpicker
checkbox
toggle
```

## File input

```@docs
filepicker
```

## Range input

```@docs
slider
```

## Callback input

```@docs
button
```
## HTML5 input

All of the inputs above are implemented wrapping the `input` tag of HTML5 which can be accessed more directly as follows:

```@docs
InteractBase.input
```

## Option input

```@docs
dropdown
togglebuttons
radiobuttons
```
