using Markdown

# Home page.

pkgname(name="Escher") = title(3, name)

using Color
angleᵗ = Input(0) # The angle at any given time
connected_slider = subscribe(slider(0:360), angleᵗ)

reactive_eg = lift(angleᵗ) do angle
    vbox(
        connected_slider,
        size(5em, 5em, empty) |>
            fillcolor(HSV(angle, 1.0, 1.0))
    )
end

part1 = md"""

$(vskip(1em))
$(

fontsize(1.33em,
     "Escher lets you to build beautiful, interactive Web UIs in pure Julia.") |>
        textalign(centertext) |>
        fontstyle(italic)
)

$(vskip(1em))

It comes with:

**A web server for 2015.** the built-in web server allows you to create interactive UIs with very little code. It takes care of messaging between Julia and the browser under-the-hood. It can also hot-load code: you can see your UI evolve as you save your changes to it.

**A rich functional library of UI components.** the built-in library functions support Markdown, Input widgets, TeX-style Layouts, Styling, LaTeX, Code, Behaviors, Tabs, Menus, Slideshows, Plots (via [Gadfly](http://gadfly.org)) and Vector Graphics (via [Compose](http://composejl.org)) -- everything a Julia programmer would need to effectively visualize data or to create user-facing GUIs.
 

$(vskip(1em))

# Installation

$(vskip(1em))

```julia
Pkg.add("Escher")
```

$(vskip(1em))
You might want to link escher executable to `/usr/local/bin` so that it goes in your PATH.

$(vskip(1em))
```sh
ln -s ~/.julia/v0.4/Escher/bin/escher /usr/local/bin/
```

$(vskip(1em))
## Starting the server
$(vskip(1em))

A great way to get started is by looking at the examples.

From the `examples/` directory in `~/.julia/v0.3/Escher`, run the following command to bring up the escher server:

```
../bin/escher --serve
```

This will start a web server on port 5555. See `escher --help` for other options to this command. You can now point your browser to `http://localhost:5555/` to access the examples viewer interface. Or you can also visit `http://localhost:5555/<file>.jl` to access a specific example. `<file>.jl` could be any file inside the `examples/` directory. In general, any file with a `main` function that takes one argument-the `Window` object, and returns a valid Escher UI is served in this way.

The following section will give a general overview of how UIs are created with Escher.


$(vskip(1em))
# An overview
$(vskip(1em))

These are the rules Escher is built around.

$(vskip(1em))

## Rule 0: UIs are immutable values

$(vskip(1em))
A UI in Escher is simply an immutable Julia value of the abstract type `Tile`. A Tile is rendered into a browser [DOM tree](http://en.wikipedia.org/wiki/Document_Object_Model) to actually display the UI.

As an example `plaintext("Hello, World!")` is a Tile that contains the plain text 'Hello, World!'.

Create a file called `hello.jl` in `examples/` directory, and put in the following code in it:

$(vskip(1em))
```julia
function main(window)
    plaintext("Hello, World!")
end
```
$(vskip(1em))

Now if you visit `http://localhost:5555/hello.jl` you should see the text "Hello, World!" on the top left corner of the screen.

Notice the argument `window`. `main` *must* take this argument, and may or may not use it. Briefly, `window.assets` is an input signal which can be used to load HTML dependencies on-the-fly. `window.alive` is a boolean signal that tells you if the window is still open. `window.dimension` is a 2-tuple of lengths representing the current size of the window in pixels.

$(vskip(1em))
## Rule 1: Functions that modify a UI return a new UI

$(vskip(1em))
Now let us say you want to give a padding of 10mm around the plain text tile you created in the hello world example, you do it by passing the previous value to the function `pad`.

```julia
function main(window)
    txt = plaintext("Hello, World!")
    pad(10mm, txt)
end
```

Similarly, if you want to change some style in/of a UI, you call a function to do it. For example, to make the Hello, World text red, you could use `fontcolor`:

$(vskip(1em))
```julia
function main(window)
    txt = plaintext("Hello, World!")
    fontcolor("red", pad(10mm, txt))
end
```
$(vskip(1em))

## Rule 2: Most Escher functions have curried methods
$(vskip(1em))

Omitting the last tile argument to most escher functions returns a 1-argument function that takes a tile and applies the property.

For example, `pad(10mm)` returns an anonymous function of 1 argument which must be a tile, and that returns a new tile with the specified 10mm of padding.

Therefore, `pad(10mm, txt)` is equivalent to `pad(10mm)(txt)` or `txt |> pad(10mm)`. This is helpful when you want to apply, for example, the same padding to a all the tiles in a vector. e.g. `map(pad(10mm), [tile1, tile2])` will return a vector of two tiles with 10mm padding each.

Moreover, using the curried version with the `|>` infix operator makes for code that reads better. For example, the previous Hello World example could also be written like this:

$(vskip(1em))
```julia
function main(window)
    plaintext("Hello, World!") |>
        fontcolor("red") |>
        pad(10mm)
end
```
$(vskip(1em))

You can mentally read this as: to the plaintext Hello, World, apply font color red and then apply a padding of `10mm`.

$(vskip(1em))
## Rule 3: layout functions combine many UIs into one
$(vskip(1em))

To stack tiles vertically, use `vbox`. To stack horizontally, use `hbox`.

For example

```julia
hello_color(color) =
    plaintext("Hello, World!") |>
        fontcolor(color) |>
        pad(10mm)

function main(window)
    x = vbox(
        hello_color("red"),
        hello_color("blue"),
        hello_color("green"),
    )
    y = vbox(
        hello_color("green"),
        hello_color("red"),
        hello_color("blue"),
    )

    hbox(x, y)
end
```

$(vskip(1em))
Should result in an arrangement like this:

$(begin
    hello_color(color) =
        plaintext("Hello, World!") |>
            fontcolor(color) |>
            pad(1em)

    x = vbox(
        hello_color("red"),
        hello_color("blue"),
        hello_color("green"),
    )
    y = vbox(
        hello_color("green"),
        hello_color("red"),
        hello_color("blue"),
    )

    hbox(x, y)
end)

`x` and `y` are vertial arrangements of 3 tiles each, these arrangements are themselves put in a `hbox` to place `x` next to `y`.

Other functions that combine multiple UIs include: `menu`, `pages`, `tabs`, and so on, these are defined in `src/library/layout2.jl`.

$(vskip(1em))
## Rule 4: An interactive UI is a Signal of UIs
$(vskip(1em))

To get an overview of how Reactive.jl's signals work, see [Reactive documentation](http://julialang.org/Reactive.jl).

There are two facets to this rule:

1. Getting the input from tiles
2. Creating a signal of UI using these signals

Firstly, some Tiles (particularly those that are subtypes of `Behavior` which is in turn a subtype of `Tile`) can write to `Input` signals from Reactive. Widgets such as sliders, buttons, dropdown menus are subtypes of `Behavior`. `subscribe` lets you pipe updates from a behavior into a signal.

For example

```julia

angleᵗ = Input(0) # The angle at any given time
connected_slider = subscribe(slider(0:360), angleᵗ)
```

Now `connected_slider` renders as a slider and updates the signal `angleᵗ` when the slider's knob is moved by the user.

Secondly, you can use these input signals to create a signal of Escher UIs. For example,

```julia

using Color # for HSV

function main(window)
    # First, load HTML dependencies related to the slider
    push!(window.assets, "widgets")

    angleᵗ = Input(0) # The angle at any given time
    connected_slider = subscribe(slider(0:360), angleᵗ)

    lift(angleᵗ) do angle
        vbox(
            connected_slider,
            size(5em, 5em, empty) |>
                fillcolor(HSV(angle, 1.0, 1.0))
                             # ^^^ Use the current slider angle
        )
    end
end
```
"""

part2 = md""

include("helpers/page.jl")
function main(window)
    push!(window.assets, "latex")
    push!(window.assets, "widgets")

    lift(reactive_eg) do example
        vbox(
            pkgname(),
            vskip(1em),
            part1,
            example,
            part2,
        ) |> centeredpage
    end
end
