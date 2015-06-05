using Markdown
using Color
import Compose: compose, context, polygon
using Lazy
using Gadfly

import Escher: @d

# Home page.

pkgname(name="Escher") =
    hbox(title(3, name), hskip(1em), Escher.latex("\\beta")) |> fontcolor("#999")

*(f::Function, g::Function) = x -> f(g(x))

sidenote(note, icon="info", iconcolor="#aaa") =
    hbox(Escher.icon(icon) |>
            size(100px, 100px) |>
            fontcolor(iconcolor),
        hskip(4em),
        note |>
           fontsize(0.9em) * fontcolor("#666")) |>
        pad(1em) |>
        bordercolor("#e1e1e1") |>
        Escher.borderstyle([top, bottom], solid) |>
        Escher.borderwidth([top, bottom], 1px)

angleᵗ = Input(0) # The angle at any given time
connected_slider = subscribe(slider(0:360), angleᵗ)

reactive_eg = lift(angleᵗ) do angle
    vbox(
        connected_slider,
        size(5em, 5em, empty) |>
            fillcolor(HSV(angle, 1.0, 1.0))
    )
end

function sierpinski(n)
    if n == 0
        compose(context(), polygon([(1,1), (0,1), (1/2, 0)]))
    else
        t = sierpinski(n - 1)
        compose(context(),
                (context(1/4,   0, 1/2, 1/2), t),
                (context(  0, 1/2, 1/2, 1/2), t),
                (context(1/2, 1/2, 1/2, 1/2), t))
    end
end

tex_eg = """f(x) = \\int_{-\\infty}^\\infty
    \\hat f(\\xi)\,e^{2 \\pi i \\xi x}
    \\,d\\xi
"""
md_example = md"""**Things to do:**

- Create *universe*
- Make a *pie*
"""

part1 = md"""

$(vskip(1em))
$(

vbox(
hline(color=color("#e1e1e1")),
vskip(2em),
Escher.fontsize(2em,
     "Escher lets you build beautiful interactive Web UIs in Julia.") |>
        textalign(centertext) |>
        fontweight(200) |>
        lineheight(1.2em) |>
        maxwidth(15em) |>
        x -> hbox(flex(), x, flex()),
vskip(2em),
hline(color=color("#e1e1e1")),
)
)
$(vskip(3em))

$(title(2, "What's inside") |> Escher.fontsize(1.75em))

$(
vbox(md"**A web server for 2015.** Escher's built-in web server allows you to create interactive UIs with very little code. It takes care of messaging between Julia and the browser under-the-hood. It can also hot-load code: you can see your UI evolve as you save your changes to it.",

md"**A rich functional library of UI components.** the built-in library functions support Markdown, Input widgets, TeX-style Layouts, Styling, LaTeX, Code, Behaviors, Tabs, Menus, Slideshows, Plots (via [Gadfly](http://gadfly.org)) and Vector Graphics (via [Compose](http://composejl.org)) -- everything a Julia programmer would need to effectively visualize data or to create user-facing GUIs. The API comprehensively covers features from HTML and CSS, and also provides advanced features. Its user merely needs to know how to write code in Julia."
) |> pad([left, right], 2em)
)

$(vskip(2em))

# Installation

In a Julia REPL, run:

```julia
Pkg.add("Escher")
```

You might want to link escher executable to `/usr/local/bin` so that it goes in your PATH.

```sh
ln -s ~/.julia/v0.4/Escher/bin/escher /usr/local/bin/
```

# Usage

From the directory from which you want to serve files containing Escher UIs, run:

```
<Escher-package-path/bin>/escher --serve
```


From the `examples/` directory in `~/.julia/v0.3/Escher`, run the following command to bring up the escher server:


This will start a web server on port 5555. See `escher --help` for other options to this command. You can now point your browser to `http://localhost:5555/` to access the examples viewer interface. Or you can also visit `http://localhost:5555/<file>.jl` to access a specific example. `<file>.jl` could be any file inside the `examples/` directory. In general, any file with a `main` function that takes one argument-the `Window` object, and returns a valid Escher UI is served in this way.

The following section will give a general overview of how UIs are created with Escher.


# An Overview

Escher is built around 5 rules. Understanding these rules gives you a foundation to understanding Escher's comprehensive API.

## Rule 1: UIs are immutable values

A UI in Escher is simply an immutable Julia value of the abstract type `Tile`. A Tile is rendered into a browser [DOM tree](http://en.wikipedia.org/wiki/Document_Object_Model) to actually display the UI.

Escher has all kinds of functions that generate Tiles.


**Example 1.**

`plaintext("Hello, World!")` is a Tile that contains the plain text 'Hello, World!'.

To actually see this in action, create a file called `hello.jl` in an directory where the Escher server is running. Save the following code in it:

```julia
function main(window)
    plaintext("Hello, World!")
end
```

Now if you visit `http://localhost:5555/hello.jl` you should see the text "Hello, World!" on the top left corner of the screen.

$(vskip(1em))
$(sidenote(md"The function `main` *must* take a window argument, and may or may not use it. The `window` object contains some information about the current browser window. Specifically, `window.assets` is an input signal which can be used to load HTML dependencies on-the-fly. `window.alive` is a boolean signal that tells you if the window is still open. `window.dimension` is a 2-tuple representing the current size of the window in pixels."))
$(vskip(1em))

**Example 2.**

The `md""` string macro can generate markdown tiles from a markdown string.
```julia
using Markdown

function main(window)
    md\"\"\"
**Things to do:**

- Create *universe*
- Make a *pie*
    \"\"\"
end
```

*Output:*

$(md_example |> pad([left], 4em))

**Example 3.**

The `latex` function creates a LaTeX tile.
```julia
function main(window)
    push!(window.assets, "latex")

    latex(\"\"\"f(x) = \int_{-\infty}^\infty
        \hat f(\xi)\,e^{2 \pi i \xi x}
        \,d\xi\"\"\")
end
```
*Output:*

$(Escher.latex(tex_eg, block=true))


**Example 3.**

[Gadfly](http://gadflyjl.org) plots are essentially immutable values too. Escher type-casts Gadfly plots to tiles.

```julia
using Gadfly

function main(window)
    plot(z=(x,y) -> x*exp(-(x-int(x))^2-y^2),
         x=linspace(-8,8,150), y=linspace(-2,2,150), Geom.contour)
end
```
*Output:*

$(
plot(z=(x,y) -> x*exp(-(x-int(x))^2-y^2),
     x=linspace(-8,8,150), y=linspace(-2,2,150), Geom.contour)

)

**Example 4.**

[Compose](http://composejl.org) graphics work the same way.

```julia
using Compose
using Color

function sierpinski(n)
    if n == 0
        compose(context(), polygon([(1,1), (0,1), (1/2, 0)]))
    else
        t = sierpinski(n - 1)
        compose(context(),
                (context(1/4,   0, 1/2, 1/2), t),
                (context(  0, 1/2, 1/2, 1/2), t),
                (context(1/2, 1/2, 1/2, 1/2), t))
    end
end

main(window) = compose(sierpinski(6))

```
*Output:*

$(vskip(2em))
$(drawing(3Compose.inch, sqrt(3)/2*3Compose.inch, compose(sierpinski(6))) |> pad([left], 8em))

## Rule 2: Functions that modify a UI return a *new* UI

$(vskip(0.5em))
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

## Rule 3: Most Escher functions have curried methods
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
## Rule 4: layout functions combine many UIs into one
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
## Rule 5: An interactive UI is a Signal of UIs
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
    push!(window.assets, "codemirror")

    lift(reactive_eg) do example
        vbox(
            pkgname(),
            vskip(1em),
            part1,
            example,
            part2,
        ) |> docpage
    end
end
