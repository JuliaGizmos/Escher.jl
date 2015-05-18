using Markdown
using Color

include("helpers/page.jl")

xᵗ = Input(0)
x2ᵗ = Input(0)

intro = lift(xᵗ, x2ᵗ) do x, x2
    md"""
$(h2("User Guide") |> fontweight(200))
$(vskip(1em))
$(title(2, "Reactive programming and Interactive GUIs"))
$(vskip(1em))


The default and dominant pattern used for creating interactive GUIs on the Web has been the use of *callbacks*. A **callback** is a function that is intended to be called at a later time when a certain event such as a key press, a mouse click or a HTTP response occurs. A callback usually contains code that will inspect the event (e.g. check which key was pressed, or look into the data from a HTTP response), and, usually, *select* and *mutate* elements on the page to reflect the intended changes to the UI (e.g. increment a counter, or updating a list using data that arrived in a HTTP response)

In this pattern there is a wide conceptual gap between the programmer's intention and the code he/she actually needs to write: instead of simply expressing *what* needs to happen, you need to code every step of *how* it needs to happen.

Although the callback-style of programming has served web developers well, there is an increasing awareness that this style is unproductive: firstly, it is verbose, resulting in more code, and hence more surface area for bugs; secondly, explicitly maintaining document state and mutating the `document` object is a great way to end up with messy, non-reusable code. The focus of modern web frameworks like React, Rx JS, Elm and Mercury has been to provide better abstractions over the callback-style of programming. The following section talks about *reactive programming*, Escher's choice of paradigm for making event-driven UIs *without* callbacks.

$(vskip(1em))
# What is reactive programming?
$(vskip(1em))

*Reactive programming* is a style of talking about event-driven programs in terms of **streams of data**. For example, a keyboard gives out a *stream of key presses*, a timer gives out a *stream of timestamps*, a mouse gives out a *stream of clicks*. More interestingly, an interactive UI is itself a stream of UIs!

**Signals**

Escher makes use of the [Reactive.jl](https://github.com/JuliaLang/Reactive.jl) package for reactive programming. In Reactive, a *stream of data* is called a **Signal**. The name Signal signifies the continuous nature of these streams--a signal always contains a value at any given time. Reactive.jl provides a toolkit of premitives to create, combine, and filter Signals. In the following section we discuss `Input` and `consume` -- the two most important primives of Reactive.jl used to create signals.

$(vskip(1em))
# Creating interaction: `Input`, `subscribe` and `consume`
$(vskip(1em))

An *input signal* is created using the `Input` constructor.

For example, in

```julia
    xᵗ = Input(0)
```

`xᵗ` is an input signal containing a value of type Int64, initially, 0.

Updates to an input signal can be obtained from a widget in the UI. This is done by *subscribing* the input signal to a widget's updates.

To illustrate this, we will first create a slider widget. The `slider` function takes a range object and returns a slider widget. Here is a slider that can be used to select integer values between 0 to 360.

```julia
    slider(0:360)
```
$(slider(0:360))

If you move the slider knob, you can see the value of the slider changing. Let us go ahead and *subscribe* slider movements to the signal `xᵗ`.

```julia
    subscribe(slider(0:360), xᵗ)
```
$(begin
    slider(0:360)
end)

`subscribe(slider(0:360), xᵗ)` *returns a new slider* which sends its updates to the xᵗ signal. The next step in making an interactive UI is to actually use the `xᵗ` signal to make something useful. This can be done using `consume`.

`consume` applies a function to every value of a given signal and results in a new signal. Specifically, the call `consume(f, xᵗ)` takes a function `f` and a signal `xᵗ` and returns a new signal, `yᵗ` which is such that every update `x` to `xᵗ` will update `yᵗ` with the value `f(x)`.

Let's say we want to use the slider to set the hue of a rectangle in the UI. The statement of this problem naturally guides the next step -- we need a function that given the slider value, returns a rectangle with a specific hue.

```julia
    using Color

    with_hue(hue, tile=size(6em, 6em, empty)) =
        fillcolor(HSV(hue, 0.6, 0.6), tile) # HSV color space
```

Let's see if this function actually works by drawing colored squares for hues in the range 0:45:270.

```julia
    hbox(intersperse(hskip(1em), map(with_hue, 0:45:270)))
```

$(begin
    with_hue(hue, tile=size(4em, 4em, empty)) =
        fillcolor(Color.HSV(hue, 0.6, 0.6), tile)

    hbox(intersperse(hskip(1em), map(with_hue, 0:45:270))) |> hbox |> packitems(center) |> fig
end)

But `with_hue` is not enough. We want the slider to be present in the final UI as well, otherwise we have no way of updating a slider that is not displayed. So the full UI function which depends on the hue value can be something like:

```julia
   slider_and_huebox(hue) = vbox(
        subscribe(slider(0:360), xᵗ),
        "The current hue is: $hue",
        with_hue(hue)
    )
```

Now to consume `xᵗ` to produce our desired result.

```julia
    consume(slider_and_huebox, xᵗ)
```
$(begin
    vbox(
        subscribe(slider(0:360), xᵗ),
        "The current hue is: $x",
        with_hue(x)
    ) |> hbox |> packitems(center)
end)

Voila! We have our first interactive UI.

We can play with the `slider_and_huebox` function and make things more interesting:

```julia
   slider_and_huebox(hue) = vbox(
        subscribe(slider(0:360), xᵗ),
        "The current hue offset is: $hue",
        hbox(intersperse(hskip(1em), map(with_hue, (0:45:270) + hue)))
    )
```

$(begin
    vbox(
        subscribe(slider(0:360), x2ᵗ),
        "The current hue offset is: $x2",
        hbox(intersperse(hskip(1em), map(with_hue, (0:45:270) + x2)))
    ) |> hbox |> packitems(center)
end)
$(vskip(1em))

`consume` is not limited to a single input, if the first argument to `consume` is a function that takes N arguments, you can give N signals as the input to this function. To illustrate this, we will create a [Compose](http://composejl.org/) graphic which contains a shape which can be selected from a group of radio buttons, rotated at a certain angle chosen using a slider.


**OK NOW I"M OFF FIXING RADIOBUTTONS BRB**
"""
end

function main(window)
    push!(window.assets, "widgets")
    lift(centeredpage, intro)
end
