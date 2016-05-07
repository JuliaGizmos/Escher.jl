# Escher

[![Build Status](https://travis-ci.org/shashi/Escher.jl.svg?branch=master)](https://travis-ci.org/shashi/Escher.jl)

**A web server for 2016.** Escher's built-in web server allows you to create interactive Julia UIs with very little code. It takes care of messaging between Julia and the browser under-the-hood. It can also hot-load code: you can see your UI evolve as you save your changes to it.

**Escher provides an easy to use rich functional library of UI components:** the built-in library functions support Markdown, Signal widgets, TeX-style Layouts, Styling, TeX, Code, Behaviors, Tabs, Menus, Slideshows, Plots (via [Gadfly](http://dcjones.github.io/Gadfly.jl/), [Vega](http://johnmyleswhite.github.io/Vega.jl/), [VegaLite](https://github.com/fredo-dedup/VegaLite.jl)) and Vector Graphics (via [Compose](http://composejl.org/)) – everything a Julia programmer would need to effectively visualize data or to create user-facing GUIs. The API comprehensively covers features from HTML and CSS, and also provides advanced features. Its user merely needs to know how to write code in Julia.


Join the Gitter Chat room: [![Gitter](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/shashi/Escher.jl?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)

Go to [Escher webpage](http://escher-jl.org/).

## 1. Installation

To add the Escher package to Julia environment, in a Julia REPL, run:

```julia
julia> Pkg.add("Escher")
```

You might want to link escher executable `~/.julia/vX.Y/Escher/bin/escher` to `/usr/local/bin` or somewhere in your `PATH`, especially if you want to start Escher Server from the CLI:

```sh
$ ln -s ~/.julia/v0.4/Escher/bin/escher /usr/local/bin/
```

## 2. Usage

Escher comes with a few example files, you may use them to learn more about the framework. The examples are located in the `examples/` folder in the julia `Escher` package folder, usually `~/.julia/vX.Y/Escher/examples`.

### 2.1. Start the server

The Escher server will start a web server on port 5555 (default).

#### a. From the terminal /CLI

Go to a directory from which you want to serve Escher UI files. You can start with the examples folder.
```sh
$ cd <path-to-escher-ui-files>
```
Run the server. You do not need the path `<Escher-package-path/bin>` if you created the link mentioned at previous step.
```sh
$ <Escher-package-path/bin>/escher --serve
```

See `escher --help` for other options to the executable.

#### b. From the Julia REPL

Load the Escher package and `serve.jl` file.
```julia
julia> using Escher
julia> include(Pkg.dir("Escher", "src", "cli", "serve.jl"))
```

Move to a directory from which you want to serve Escher UI files. Below, we use the examples folder.
```julia
julia> cd(Pkg.dir("Escher", "examples"))
```
Start the Escher Server.
```julia
julia> escher_serve()
```

### 2.2. Load UI

Visit `http://localhost:5555/<file-name.jl>` to see the output.

Please Note:
- if you leave out the file name it will default to `index.jl`.
- files containing plots may take a while to load the first time you visit them.
- if you run Escher in a virtual machine or container environment, you may need to adjust the local host address.


## 3. Escher UI file format



The most basic Julia Escher UI file may be summed up as below:

```julia
# user outer_code

function main(window)

  # user inner_code

  UI_expression
end
```

where:

- user `outer_code` should contain code required to generate and support the UI (`using`, `import`, function definitions etc.).
- the `main` function definition is required and must take a `window` argument, even if it may not use it.
- the `window` object contains some information about the current browser window. Specifically, `window.assets` is an input signal which can be used to load HTML dependencies on-the-fly. `window.alive` is a boolean signal that tells you if the window is still open. `window.dimension` is a 2-tuple representing the current size of the window in pixels.
- user `inner_code` should contain code needed for rendering. Such code may be pushing HTML assets to `window.assets` and preparing the content and layout, explained in the UI Build Guide.
- as with any Julia function, if `return` keyword is missing, the last expression is returned.
- the returned `UI_expression` is the one used to generate the UI, so everything you need to render needs to be inside it. One can build complex webpages using the layouts API to package the content, explained in the UI Build Guide.


## 4. UI Build Guide

### 4.1. Escher foundation

Escher functionality is based on the
[Web Components Standard](https://developer.mozilla.org/en-US/docs/Web/Web_Components)
and makes use of the
[Google Polymer](https://www.polymer-project.org/1.0/docs/start/what-is-polymer.html)
libraries.

> Web Components consists of several separate technologies. You can think of Web Components as reusable user interface widgets that are created using open Web technology. They are part of the browser, and so they do not need external libraries like jQuery or Dojo. An existing Web Component can be used without writing code, simply by adding an import statement to an HTML page. Web Components use new or still-developing standard browser capabilities.

Web Components consists of these four technologies (although each can be used separately):

- [Custom Elements](https://developer.mozilla.org/en-US/docs/Web/Web_Components/Custom_Elements)
- [HTML Templates](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/template)
- [Shadow DOM](https://developer.mozilla.org/en-US/docs/Web/Web_Components/Shadow_DOM)
- [HTML Imports](https://developer.mozilla.org/en-US/docs/Web/Web_Components/HTML_Imports)

The basic functionality of Escher may be represented as follows:
`UI_expression -> Shadow DOM -> DOM`. While the `UI_expression` and the `Shadow DOM` or `Virtual DOM` runs on the server, the `DOM` is run on the client side. The `Virtual DOM` is made available via the [Patchwork.jl](https://github.com/shashi/Patchwork.jl) package. Escher works with `Tile` types and the `Virtual DOM` works with the `Elem` type, so the rendering chain can be written as `Tile -> Elem -> HTML + JS`.

Escher uses a bunch of custom HTML elements as well as an off-the-shelf library of [Polymer elements](https://elements.polymer-project.org/). All HTML Templates are stored inside the `assets/` folder in Escher. Basic elements are loaded by default, like [Signal](http://escher-jl.org/signal-api.html) `signals.html`, [Behavior](http://escher-jl.org/behavior-api.html) `behavior.html` and other basic third party custom element libraries (including some Polymer).

HTML Templates for dependencies which are not always required ([Widgets](http://escher-jl.org/widgets-api.html) `widgets.html`, [CodeMirror](http://escher-jl.org/widgets-api.html)  `codemirror.html`, [TeX](http://escher-jl.org/tex-api.html) `tex.html` etc.) are also stored in the `assets/` folder, but the user has to load them specifically:

- multiple templates may be defined in the same HTML file.
- if the template required is inside an `templates.html` file, the user can call `push!(window.assets, "templates")` to load that file as an HTML import. Please notice that only the filename `"templates"`, no extension, is used in the method call.
- the `push!` method is called once per file, inside the `main` function, usually as the first lines in the `user inner_code`.

For your reference, the default HTML content of the `assets/` folder is listed below:

no | HTML file | content | API | loading-time
-- | ----- | ----------- | --- | ----------
1 | animations.html | HTML animations elements | - | user
2 | basics.html | imported by every Escher page implicitly. It loads Polymer, escherd.html, signals.html, behavior.html and the default stylesheets, in that order. | | auto
3 | behaviour.html |  contains custom elements used to set up the most basic event handlers, such as clickable-behavior, keypress-behavior, watch-state (fired when some attribute of the parent changes). | [Behavior](http://escher-jl.org/behavior-api.html) | auto
4 | camera.html | camera widget custom element | - | user
5 | codemirror.html | codemirror HTML element | [Widgets](http://escher-jl.org/widgets-api.html) | user
6 | date.html | datepicker HTML element | [Widgets](http://escher-jl.org/widgets-api.html) | user
7 | escherd.html | it sets up the comunications with the browser side code | | auto
8 | icons.html | icon and icon button elements | [Higher Order Layouts](http://escher-jl.org/layout2-api.html) | user
9 | layout2.html | advanced layout elements like menus, tabs, pages etc. | [Higher Order Layouts](http://escher-jl.org/layout2-api.html) | user
10 | signals.html | the elements here correspond to those rendered by basics/signal.jl signal-transport element, which is used to annotate that another element would like to send some events to the server. | [Signal](http://escher-jl.org/signal-api.html) | auto
11 | tex.html | TeX/LaTeX element | [TeX](http://escher-jl.org/tex-api.html) | user
12 | widgets.html | interactive HTML elements like buttons, text input etc. | [Widgets](http://escher-jl.org/widgets-api.html) | user

For detailed information, not required for general use, please read the Browser-Side Section of this [documentation](https://github.com/shashi/Escher.jl/blob/master/DEVDOCS.md).

### 4.2. Escher Basics

Escher introduces the Julia abstract immutable type `Tile`. Every rendable UI element is a subtype of `Tile`. The return expression of the function `main()`, named `UI_expression` in chapter 3, is a `Tile`.

The Escher Type tree looks something like this:

```julia
Tile :> Concrete_Subtypes
     :> Behavior :> Concrete_Subtypes
                 :> Widget :> Concrete_Subtypes
                           :> Selection :> Concrete_Subtypes
     :> Flex Container :> Concrete_Subtypes
```

You can navigate the Type tree using the Julia `super(Type)` and `subtypes(Type)`, or, if you want a detailed overview, use the function below. The code was taken from the [Julia Wikibooks page](https://en.wikibooks.org/wiki/Introducing_Julia/Types).

```julia
level = 0
function showtypetree(subtype)
    global level
    subtypelist = filter(asubtype -> asubtype != Any, subtypes(subtype))
    if length(subtypelist) > 0
         println("\t" ^ level, subtype)        
         level += 1
         map(showtypetree, subtypelist)
         level -= 1
    else
         println("\t" ^ level, subtype)
    end    
end
```

Run the function on the `Tile` type to get a detailed overview.

```julia
julia> showtypetree(Tile)
```

#### 4.2.1. Create Tiles

##### 4.2.1.1. Create Empty Tile

A special kind of `Tile` is the `Escher.Empty`, a concrete subtype of `Escher.Tile` type. It can be created using the `empty` keyword. The following example code will create an empty "orange" `Tile` with the size of `10em` x `10em`:

**Example:**
```julia
function main(window)
    fillcolor("orange", size(10em, 10em, empty))
end
```

A second kind of empty tiles are created with the `hline` and `vline` functions, from the [Embellishment API](http://escher-jl.org/embellishment-api.html). These are used to create horizontal and vertical lines, and they return bordered tiles of height or width `0`.

##### 4.2.1.2. Create Text Tiles

Functions that can take textual arguments and return a `Tile` are found in the **Typography API**. Some of these functions are `plaintext`, `heading`, `h1`, `h2`, `h3`, `h4`, `title`, `blockquote` and `code`. For detailed information, please see the [documentation](http://escher-jl.org/typography-api.html).

**Example:**
```julia
function main(window)
    plaintext("Hello, World!")
end
```

##### 4.2.1.3. Other Content Tiles

Other kind of content can be created using the `list`, `image`, `link` and `abbr` functions. Detailed information is available in the [Content API](http://escher-jl.org/content-api.html).

##### 4.2.1.4. Create Markdown Tiles

A special case for creating tiles is the Markdown tile. The `md""` string macro can generate markdown tiles from a markdown string.

**Example:**
```julia
function main(window)
    md"""
**Things to do:**

- Create *universe*
- Make a *pie*
"""
end
```

##### 4.2.1.5. Create TeX Tiles

The `tex` function creates a TeX tile. This one requires to load the `"tex"` asset.

**Example:**
```julia
function main(window)
    push!(window.assets, "tex")

    tex("cos(x)")
end
```

##### 4.2.1.6. Create Plot Tiles

[Gadfly](http://gadflyjl.org/) plots are essentially immutable values too. Escher type-casts Gadfly plots to tiles. Gadfly module is not loaded by default, it may take a while to load for the first time.

**Example:**
```julia
using Gadfly

function main(window)
    plot(z=(x,y) -> x*exp(-(x-int(x))^2-y^2), x=linspace(-8,8,150), y=linspace(-2,2,150), Geom.contour)
end
```

##### 4.2.1.7. Create Vector Graphics

[Compose](http://composejl.org/) graphics work the same way as Gadfly plots. Compose and Color madules are not loaded by default.

**Example:**
```julia
using Compose
using Colors

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

The last line from previous example is a shorthand notation to the following code:

```julia
function main(window)
    compose(sierpinski(6)
end
```

##### 4.2.1.8. Converting other Types to Tile

If, instead of `Tile`, other type of value is used, Escher will try to convert it to one. One such examples is using textual data, like `String`. The next line of code is valid and will return a `Tile` with the content `"Simple text"` and a `1em` padding.

```julia
function main(window)
    pad(1em, "Simple text")
end
```


#### 4.2.2. Customize Tiles

Tiles are immutable, when a function is said to modify a `Tile`, it instead returns a different `Tile` with the required specifications.

For the text tiles, there are some specific functions that apply to text, like `fontsize`, `fontfamily`, `fontcolor` etc., in the [Typography API](http://escher-jl.org/typography-api.html).

For general `Tile` use, like `border`, `bordercolor`, `borderwidth` etc., you can use the [Embellishment API](http://escher-jl.org/embellishment-api.html).

#### 4.2.3. Layouts

##### 4.2.3.1. Basic Layouts

Escher provides primitives like `hbox`, `vbox`, `hskip`, `vskip`, and `flex` for laying out tiles into grids. Complex layouts can be composed from smaller parts. For detailed information, please read the [Guide](http://escher-jl.org/layout-guide.html) and the [Layout API](http://escher-jl.org/layout-api.html).

**Example**
```julia
a,b,c,d = map(fillcolor, ["#837", "#859", "#892", "#875"],
    map(pad([left, right], 1em), ["A", "B", "C", "D"]))

function main(window)
    x = vbox(a, b, c, d)
    y = vbox(d, c, b, a)

    hbox(x, y)
end
```
`x` and `y` are vertial arrangements of 4 tiles each, these arrangements are themselves put in a `hbox` to place `x` next to `y`.

##### 4.2.3.2. Higher Order Layouts

The [Higher Order Layout API](http://escher-jl.org/layout2-api.html) provides ready-to-use interactive `Tiles` like tabs, pages, menus etc.

**Examples**
```julia
function main(window)
    # create the tabs
    tabbar = tabs([
        hbox(icon("face"), hskip(1em), "Tab 1"),
        hbox(icon("explore"), hskip(1em), "Tab 2"),
        hbox(icon("extension"), hskip(1em), "Tab 3"),
    ])

    # create the pages
    tabcontent = pages([
        sierpinski(5),
        plot([sin, cos], 0, 25),
        title(3, "web component all the things"),
    ])

    # connect the tabs to pages
    # returns a pair of "connected" tab set and pages
    t, p = wire(tabbar, tabcontent, :tab_channel, :selected)

    # stack them on top of each other
    vbox(t, p)
end
```

The `pages` function combines tiles into a set of pages - only a single page is visible at a time. Pages can be combined with `tabs` to allow switching between pages.

A special case is the [Slideshow API](http://escher-jl.org/slideshow-api.html), used in presentations to create Julia slideshows.

Another useful feature is the `class` function found in the [Utils API](http://escher-jl.org/util-api.html).

#### 4.2.4. Syntax simplification

While it is possible to chain function calls to obtain the desired result, it quickly becomes cumbersome. Fear not, Escher functions have curried methods: omitting the last `Tile` argument to Escher functions returns a 1-argument function that takes a `Tile` argument.

`f(arguments, Tile)` = `f(arguments)(Tile)` = `Tile |> f(arguments)`

For example, `pad(10mm)` returns an anonymous function of 1 argument which must be a `Tile`, and that returns a new `Tile` with the specified 10mm of padding.
Therefore, `pad(10mm, txt)` is equivalent to `pad(10mm)(txt)` or `txt |> pad(10mm)`. This is helpful when you want to apply, for example, the same padding to a all the tiles in a vector. e.g. `map(pad(10mm), [tile1, tile2])` will return a vector of two tiles with 10mm padding each.

Moreover, using the curried version with the `|>` infix operator makes for code that reads better.


#### 4.2.5. Interactive UI

**Reactive.jl** package allows "reactive programming" in Julia. Reactive programming is a style of event-driven programming with signals of data. A signal is a value that can change over time. Reactive.jl's [documentation](http://julialang.org/Reactive.jl/) provides an overview of the `Signal` framework. At this point it is highly recommended that you read it. Also, you shold read the Escher [Signal API](http://escher-jl.org/signal-api.html).

There are two facets to this rule:
- Getting the input from tiles
- Creating a signal of UI using these signals

The **general formula** goes something like this:

```julia
function main(window)
    # load assets, in this case "widgets"
    push!(window.assets, "widgets")

    # create a signal
    input_signal = Signal(X)

    # link a widget to the input_signal to create a linked_widget / linked_signal
    linked_signal = subscribe(widget, input_signal)

    # create a Signal of UI as a return UI_expression
    # output_signal = Signal(UI_function(linked_signal)) = map(UI_function, linked_signal)
    map(UI_function, linked_signal)
end
```

Please note that the `UI_function` can be replaced with the **Do-Block Syntax** and ` map(UI_function, linked_signal)` will become
```julia
map(linked_signal) do args
    # function_body
end
```

Also note that multiple Signals can be used and passed as arguments to the UI_function.

##### 4.2.5.1. Creating a signal of UI using these signals

Some `Tiles` (particularly those that are subtypes of `Behavior` which is in turn a subtype of `Tile`) can write to Reactive's `Signal` signals. Widgets such as sliders, buttons, dropdown menus are subtypes of Behavior. The function `subscribe` lets you pipe updates from a behavior into a signal.

**Example**
```julia
function main(window)
    # load assets, in this case "widgets"
    push!(window.assets, "widgets")

    # create a Signal which holds the angle at any given time
    iterations = Signal(0)

    # create a Signal of UI as a return UI_expression
    # in this simple case, the liked_signal is passed as a UI_expression
    connected_slider = subscribe(slider(0:7), iterations)
end
```

The `connected_slider` renders as a slider and updates the signal iterations when the slider's knob is moved by the user.

##### 4.2.5.2. Getting the input from tiles

Let's now use the iterations signal to show an interactive Sierpinski's triangle.

**Example**
```julia
using Compose

function main(window)
    # Load HTML dependencies related to the slider
    push!(window.assets, "widgets")

     # create a Signal which holds the number of iterations to show
     # the starting value is 5
    iterations = Signal(5)

     # link a widget to the iterations Signal to create a connected_slider
    connected_slider = subscribe(slider(0:7, value=5), iterations)

    # create a Signal of UI as a return UI_expression
    map(iterations) do n
        vbox(
            connected_slider,
            sierpinski(n)
        )
    end
end
```

##### 4.2.5.3. Interactive Tiles

Escher provides ready-to-use `Tiles` like buttons, input, codemirror etc., in the [Widgets API](http://escher-jl.org/widgets-api.html). Keep in mind that, regular and interactive, `Tiles` can be augmented with clickable, selectable, keypress etc. behavior via the [Behavior API](http://escher-jl.org/behavior-api.html).

### 4.3. Escher Advanced
