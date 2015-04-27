using Markdown

# Home page.

pkgname(name="Escher") = title(3, name)

intro = md"""

Escher is a [Julia](https://julialang.org) package designed to give its user mastery over the Web UI.

By abstracting out HTML and CSS into a library of small, single-purpose, pure functions, Escher provides a pleasant API to create browser-based interactive documents while keeping out any boiler-plate or accidental complexity common to traditional tools. Use of Virtual DOM on both the server and the client side makes the front-end, and the back-end dichotomy disappear. In fact, the user only needs to know the basics of Julia, and does not need to know about HTML, CSS, JavaScript, or other web technologies to get started creating rich, interactive UIs with Escher.


$(vskip(1em))

## Overview of Features

$(vskip(1em))

- **A web server for 2015.**
Escher comes with a sophisticated web server that takes away the pain of working through the various hairy layers of the web. Firstly, it sets up communication directly between widgets on the client and values in the Julia code. This spares you time that you would otherwise have to spend setting up your Ajax / WebSocket endpoints, or doing event-handling. Secondly, it lets you see your UI evolve in real-time as you hack at it -- every time you save a file you are editing, Escher figures out what changes occured and patches up the UI.
- **A Rich Functional Library.**
Escher has functions to create most kinds of content you want in a web UI. Markdown, Input widgets, Layouts, Styling, LaTeX, Code, Behaviors, Tabs, Menus, Slideshows, and by way of being in the Julia ecosystem, Plots and Vector Graphics too are supported by the library out-of-the-box. Content created with it also looks great by default. The library is also *Functional* -- UIs are immutable values of the abstract type `Tile`. There are many subtypes of `Tile`, each containing some metadata and possibly other tiles. Library functions take Tiles as arguments, and return Tiles as their result.
- **Virtual DOM.**
*DOM (Document Object Model)* is the convention used by web browsers for tracking the state of an open web page by means of a large mutable data structure. A Virtual DOM is a mock representation of the actual DOM. Escher uses the [Patchwork](https://github.com/shashi/Patchwork.jl) package to create Virtual DOM objects on the Julia side and *project* them on the client browser's actual DOM. An update to any input to the Julia code (say, the user interacting with a text widget), triggers an exchange of short messages between the client and the server where the server receives the relevant input, and in return, sends a series of patches to be applied to the browser's DOM.
- **Reactive.** Reactive programming is a way of programming with inputs that can change over time. The [Reactive](http://julialang.org/Reactive.jl) Julia package reifies the concept of a time-varying value. Building an interactive UI is equivalent to constructing a signal of UIs from Input signals using [Reactive's primitives](http://julialang.org/Reactive.jl). This facilitates a declarative style of programming and spares us the trouble of DOM manipulation.
- **Built with Web Components.** - Web Components specification allows us to use custom-made HTML elements in through our Virtual DOM. Escher relies on Polymer webcomponents framework and library to provide higher-order layouts (like tabs, menus, pages), and widgets. Since complex widgets can be represented by a single custom element, it is lightweight to create and modify things on the fly once the assets are loaded. For example, a code editor widget will manifest as a single node in the Virtual DOM. Virtual DOM and Web Components hence make for a powerful combination, while supporting appealingly modular front-end code.
"""

quickguide = md"""

$(vskip(1em))

## Installation

$(vskip(1em))

See README for setup instruction.

## Getting Started

To begin with, under a new directory, create a file called `index.jl` and save the following code in it:


```julia
function main(window)
    "Hello, World!"
end
```

Now, from the same directory, run `bin/escherd` script bundled with this package. This should start a web server serving at port 8000.

If you now visit `http://localhost:8000` from your browser, you should see a page with "Hello, World!" written on the top-left corner of it. You just created your first Escher UI! Now if you edit the file to say "Hello, Julians" instead of "Hello, World!" and save it, you should see the page in the browser automatically update to reflect the change! `escherd` provides hot-loading of top-level UI files.

## WIP Documentation index

- [layout-api](layout-api.jl)
- [typography-api](typography-api.jl)
- [layout-guide](layout-guide.jl)
- [typography-guide](typography-guide.jl)

"""


#include("basics/macros.jl")
#include("basics/tile.jl")
#include("basics/util.jl")
#include("basics/length.jl")
#include("basics/signal.jl")
#include("basics/lazyload.jl")
#
#include("layout.jl")
#include("basics/typography.jl")
#include("basics/content.jl")
#include("basics/embellishment.jl")
#include("basics/behaviour.jl")
#include("basics/window.jl")
#
#include("library/markdown.jl")
#include("library/latex.jl")
#include("library/widgets.jl")
#include("library/layout2.jl")
#include("library/slideshow.jl")
#include("library/codemirror.jl")
#include("library/animation.jl")

include("helpers/page.jl")
function main(window)
    push!(window.assets, "latex")
    vbox(
        pkgname(),
        vskip(1em),
        intro,
        quickguide
    ) |> centeredpage
end
