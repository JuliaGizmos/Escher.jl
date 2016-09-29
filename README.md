# Escher

[![Build Status](https://travis-ci.org/shashi/Escher.jl.svg?branch=master)](https://travis-ci.org/shashi/Escher.jl)

**A web server for 2016.** Escher's built-in web server allows you to create interactive Julia UIs with very little code. It takes care of messaging between Julia and the browser under-the-hood. It can also hot-load code: you can see your UI evolve as you save your changes to it.

**Escher provides an easy to use rich functional library of UI components:** the built-in library functions support Markdown, Signal widgets, TeX-style Layouts, Styling, TeX, Code, Behaviors, Tabs, Menus, Slideshows, Plots (via [Gadfly](http://dcjones.github.io/Gadfly.jl/), [Vega](http://johnmyleswhite.github.io/Vega.jl/), [VegaLite](https://github.com/fredo-dedup/VegaLite.jl)) and Vector Graphics (via [Compose](http://composejl.org/)) – everything a Julia programmer would need to effectively visualize data or to create user-facing GUIs. The API comprehensively covers features from HTML and CSS, and also provides advanced features. Its user merely needs to know how to write code in Julia.


Join the Gitter Chat room: [![Gitter](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/shashi/Escher.jl?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)

## Installation

In a Julia REPL, run:

```julia
Pkg.add("Escher")
```

You might want to link escher executable `~/.julia/vX.Y/Escher/bin/escher` to `/usr/local/bin` or somewhere in your `PATH`, especially if you want to start Escher Server from the CLI:

```sh
$ ln -s ~/.julia/v0.4/Escher/bin/escher /usr/local/bin/
```

## 2. Usage

### 2.1. Start the server

The Escher server will start a web server on port 5555 (default).

#### a. From the terminal /CLI

Go to a directory from which you want to serve Escher UI files. You can start with the examples folder.
```sh
$ cd <path-to-escher-ui-files>
$ <Escher-package-path/bin>/escher --serve
```

Escher comes with a few example files, you may use them to learn more about the framework. The examples are located in the `examples/` folder in the julia `Escher` package folder, usually `~/.julia/vX.Y/Escher/examples`.

#### b. From the Julia REPL

Load the Escher package and `serve.jl` file.
```julia
julia> using Escher
julia> include(Pkg.dir("Escher", "src", "cli", "serve.jl"))
```

Move to a directory from which you want to serve Escher UI files.

```julia
julia> cd(Pkg.dir("Escher", "examples"))
```
Note:
Example files which include plots, such as plotting.jl, also require the Gadfly and ComposeDiff packages to be installed.
```julia
julia> Pkg.add("Gadfly")
julia> Pkg.add("ComposeDiff")
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

When your files get complicated, or you like to follow protocol, you may need to break the code into sections. Escher is inspired by [Elm language](http://elm-lang.org/) and borrows his file pattern:

- **Model**  : the state af your application
- **Update** : a way to update your state
- **View**   : a way to view your state as HTML

With this pattern in mind, the extended general UI Escher file looks like this:

```julia
# using, import, include statements

### Model ###
# declare functions to build your application's state
# declare types and instantiate variables to hold model data

### Update ###
# declare functions to update the state
# declare types and instantiate variables to hold update data

### View ###
# declare functions to display the state
# declare types and instantiate variables to hold view data

function main(window)
  # maybe some code
  UI_expression
end
```


## 4. UI Build Guide

### 4.1. Escher foundation

Escher functionality is based on the
[Web Components Standard](https://developer.mozilla.org/en-US/docs/Web/Web_Components). The key facility of the Web Components spec is that it gives developers the ability to create their own custom [HTML](http://www.w3schools.com/html/html_intro.asp) elements which can have pre-defined behavior which can interact with its parent / sibling / child elements.

> Web Components consists of several separate technologies. You can think of Web Components as reusable user interface widgets that are created using open Web technology. They are part of the browser, and so they do not need external libraries like jQuery or Dojo. An existing Web Component can be used without writing code, simply by adding an import statement to an HTML page. Web Components use new or still-developing standard browser capabilities.

A short explanation (for detailed explanation visit the links) of the technologies used is:

- one can create [Custom HTML Elements](https://developer.mozilla.org/en-US/docs/Web/Web_Components/Custom_Elements) to run in the Browser natively without other dependencies.
- Custom Elements are created from [HTML Templates](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/template).
- Templates must be [loaded /imported](https://developer.mozilla.org/en-US/docs/Web/Web_Components/HTML_Imports) in the webpage, once per page, to provide de source code for Created Elements.
- the webpages are stored on the Browser in a data structure called the [Document Object Model](https://developer.mozilla.org/en-US/docs/Web/API/Document_Object_Model), or DOM
- to make the interaction between the server and the browser more efficient a copy of the DOM is saved on the server, in what is called a [Local /Shadow /Virtual DOM](https://developer.mozilla.org/en-US/docs/Web/Web_Components/Shadow_DOM), and only the changes are sent to the browser.

In Escher's case, the UI starts out as a `UI_expression` `Tile` object, then gets converted /rendered to a [Patchwork.jl](https://github.com/shashi/Patchwork.jl) `Elem` object in the `Virtual DOM`, and then, the changes are sent over the network to the Browser as [JSON](http://www.json.org/), where it gets rendered as the `DOM`.

`UI_expression Escher.Tile -> Patchwork.Elem -> DOM`

The Escher `Tile` objects are bound to HTML templates. These templates consist of both custom HTML elements as well as off-the-shelf [Polymer elements](https://elements.polymer-project.org/). All HTML Templates are stored inside the `assets/` folder in Escher. Basic elements are loaded by default, like [Signal](http://escher-jl.org/signal-api.html) `signals.html`, [Behavior](http://escher-jl.org/behavior-api.html) `behavior.html` and other basic third party custom element libraries (including some Polymer).

HTML Templates for dependencies which are not always required ([Widgets](http://escher-jl.org/widgets-api.html) `widgets.html`, [CodeMirror](http://escher-jl.org/widgets-api.html)  `codemirror.html`, [TeX](http://escher-jl.org/tex-api.html) `tex.html` etc.) are also stored in the `assets/` folder, but the user has to load them specifically:

- multiple templates may be defined in the same HTML file.
- if the template required is inside an `templates.html` file, the user can call `push!(window.assets, "templates")` to load that file as an HTML import. Please notice that only the filename `"templates"`, no extension, is used in the method call.
- the `push!` method is called once per file, inside the `main` function, usually as the first lines in the `user inner_code`.

For your reference, the default HTML content of the `assets/` folder is listed below:

| no | HTML file | content | API | loading-time |
| --- | --------- | ------- | --- | ------------ |
| 1 | animations.html | HTML animations elements | - | user |
| 2 | basics.html | imported by every Escher page implicitly. It loads Polymer, escherd.html, signals.html, behavior.html and the default stylesheets, in that order. | - | auto |
| 3 | behaviour.html |  contains custom elements used to set up the most basic event handlers, such as clickable-behavior, keypress-behavior, watch-state (fired when some attribute of the parent changes). | [Behavior](http://escher-jl.org/behavior-api.html) | auto |
| 4 | camera.html | camera widget custom element | - | user |
| 5 | codemirror.html | codemirror HTML element | [Widgets](http://escher-jl.org/widgets-api.html) | user |
| 6 | date.html | datepicker HTML element | [Widgets](http://escher-jl.org/widgets-api.html) | user |
| 7 | escherd.html | it sets up the comunications with the browser side code | - | auto |
| 8 | icons.html | icon and icon button elements | [Higher Order Layouts](http://escher-jl.org/layout2-api.html) | user |
| 9 | layout2.html | advanced layout elements like menus, tabs, pages etc. | [Higher Order Layouts](http://escher-jl.org/layout2-api.html) | user |
| 10 | signals.html | the elements here correspond to those rendered by basics/signal.jl signal-transport element, which is used to annotate that another element would like to send some events to the server. | [Signal](http://escher-jl.org/signal-api.html) | auto |
| 11 | tex.html | TeX/LaTeX element | [TeX](http://escher-jl.org/tex-api.html) | user |
| 12 | widgets.html | interactive HTML elements like buttons, text input etc. | [Widgets](http://escher-jl.org/widgets-api.html) | user |

For detailed information, not required for general use, please read the Browser-Side Section of this [documentation](https://github.com/shashi/Escher.jl/blob/master/DEVDOCS.md).


### 4.2. Escher Basics

#### 4.2.1. Escher `Tile` type

Escher introduces the Julia abstract immutable type `Tile`. Every renderable UI element is a subtype of `Tile`. The return expression of the function `main()`, named `UI_expression` in chapter 3, is a `Tile`.

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

#### 4.2.2. Escher `Tile` types use cases

A **Tile** is the basic currency in Escher. Most of the functions in the Escher API take Tiles, among other things, as arguments, and return a `Tile` as the result. Tiles are immutable, once created there is no way to mutate them. When a function is said to be called on a `Tile` it actually returns a new `Tile` with the new characteristics.

A **Behavior** is a `Tile` that can result in a stream of values. The stream of values can be given intents, put into signals, used to trigger updates from other behaviors. See `subscribe`, `intent`, `sampler` and `capture` in the [Signal API](https://github.com/shashi/Escher.jl/blob/master/docs/signal-api.jl).

A **Widget** is an abstract Subtype of `Behavior`. It is used to create interactive `Tiles`.

An **Intent** is a transformation applied to the stream of values coming from a `Behavior Tile`. The purpose of an `Intent` is to turn `Widget` messages into types in the business logic of the application, JSON messages into appropriate values. Attaching an `Intent` to a `Behavior` results in a new `Behavior`. A `Widget` or a `Behavior` has a default `Intent` defined by the `default_intent` generic function. When another `Intent` is attached to a `Behavior`, it gets chained to the default `Intent`.

A **Selection** is an abstract Subtype of `Widget` used to represent elements like `DropdownMenu`, `Menu`, `Pages`, `SlideShow`, `SubMenu` or `Tabs`.

**Flex Container** is a special `Tile` that can stretch or contract inside its context based on set rules.


#### 4.2.3. Create Tiles

##### 4.2.3.1. Create Empty Tile

A special kind of `Tile` is the `Escher.Empty`, a concrete subtype of `Escher.Tile` type. It can be created using the `empty` keyword. The following example code will create an empty "orange" `Tile` with the size of `10em` x `10em`:

**Example 1: Empty tile**
```julia
function main(window)
    fillcolor("orange", size(10em, 10em, empty))
end
```

**Output:**

---------------------------------------------

![Empty Tile Output]( https://cloud.githubusercontent.com/assets/25916/15371154/d15b3bc2-1d57-11e6-8d41-1f2e5d535d78.png "Empty Tile")

---------------------------------------------

A second kind of empty tiles are created with the `hline` and `vline` functions, from the [Embellishment API](http://escher-jl.org/embellishment-api.html). These are used to create horizontal and vertical lines, and they return bordered tiles of height or width `0`.

##### 4.2.3.2. Create Text Tiles

Functions that can take textual arguments and return a `Tile` are found in the **Typography API**. Some of these functions are `plaintext`, `heading`, `h1`, `h2`, `h3`, `h4`, `title`, `blockquote` and `code`. For detailed information, please see the [documentation](http://escher-jl.org/typography-api.html).

**Example 2: Text tile**
```julia
function main(window)
    plaintext("Hello, World!")
end
```

**Output:**

---------------------------------------------

Hello World!

---------------------------------------------

##### 4.2.3.3. Other Content Tiles

Other kind of content can be created using the `list`, `image`, `link` and `abbr` functions. Detailed information is available in the [Content API](http://escher-jl.org/content-api.html).

##### 4.2.3.4. Create Markdown Tiles

A special case for creating tiles is the Markdown tile. The `md""` string macro can generate markdown tiles from a markdown string.

**Example 3: Markdown tile**
```julia
function main(window)
    md"""
**Things to do:**

- Create *universe*
- Make a *pie*
"""
end
```

**Output:**

---------------------------------------------

**Things to do:**

- Create *universe*
- Make a *pie*

---------------------------------------------

##### 4.2.3.5. Create TeX Tiles

Escher can create [TeX](https://khan.github.io/KaTeX/) `Tiles` from TeX objects using the `tex(text::LaTeXString)`. TeX asset is not loaded by default.

To create a LaTeX string there are two options:
- use the `L" "`, and `L""" """` for multi-line text, macro.
- use the `latexstring(args...)` function.

The `latexstring(args...)` works in similar fashion to `string(args...)`, supports string interpolation, but the arguments are required to have escaped characters (`\` and `$` become `\\` and `\$`). For more information about the `LaTeXString` type read [here](https://github.com/stevengj/LaTeXStrings.jl).

**Example 4: TeX tile from macro**
```julia
function main(window)
    push!(window.assets, "tex")

    tex(L"f(x) = \int_{-\infty}^\infty \hat f(\xi)\,e^{2 \pi i \xi x} \,d\xi")
end
```

**Output:**

---------------------------------------------

![TeX Tile Output](https://cloud.githubusercontent.com/assets/25916/15371196/03cd08ec-1d58-11e6-90af-b282502ad565.png "TeX Tile")

---------------------------------------------

**Example 5: TeX tile from function**
```julia
function main(window)
    push!(window.assets, "tex")

    a = "f(x) = \\int_{-\\infty}^\\infty \\hat"
    b = "f(\\xi)\\,e^{2 \\pi i \\xi x} \\,d\\xi"

    tex(latexstring(a, " ",b))
end
```

**Output:**

---------------------------------------------

![TeX Tile Output](https://cloud.githubusercontent.com/assets/25916/15371196/03cd08ec-1d58-11e6-90af-b282502ad565.png "TeX Tile")

---------------------------------------------


##### 4.2.3.6. Create Plot Tiles

[Gadfly](http://gadflyjl.org/) plots are essentially immutable values too. Escher type-casts Gadfly plots to tiles. Gadfly module is not loaded by default, it may take a while to load for the first time.

**Example 6: Gadfly Plot tile**
```julia
using Gadfly

function main(window)
    plot(z=(x,y) -> x*exp(-(x-int(x))^2-y^2),
        x=linspace(-8,8,150), y=linspace(-2,2,150), Geom.contour)
end
```

**Output:**

---------------------------------------------

![Gadfly Tile Output](https://cloud.githubusercontent.com/assets/25916/15371247/378a2890-1d58-11e6-8b1b-d5f44676d11e.png "Gadfly Tile")

---------------------------------------------

##### 4.2.3.7. Create Vector Graphics

[Compose](http://composejl.org/) graphics work the same way as Gadfly plots. Compose and Color madules are not loaded by default.

**Example 7: Compose Vector Graphics tile**
```julia
using Compose
using Colors

# define the `sierpinski` triangle function
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

**Output:**

---------------------------------------------

![Compose Tile Output](https://cloud.githubusercontent.com/assets/25916/15371280/4f11b08c-1d58-11e6-882b-73ab0fc69d9b.png "Compose Tile")

---------------------------------------------


##### 4.2.3.8. Converting other Types to Tile

If, instead of `Tile`, other type of value is used, Escher will try to convert it to one. One such examples is using textual data, like `String`. The next line of code is valid and will return a "pink" `Tile` with the content `"Simple text"` and a `1em` padding. Please note that **Compose** package exports its own version of `pad` function. For this reason it is required that you use `Escher.pad`.

**Example 8: Convert other tiles**

```julia
function main(window)
    fillcolor("pink", Escher.pad(1em, "Simple text"))
end
```

**Output:**

---------------------------------------------

![Text Tile Output](https://cloud.githubusercontent.com/assets/25916/15371304/6a17736c-1d58-11e6-9882-704d2d9813d1.png "Text Tile")

---------------------------------------------

#### 4.2.4. Customize Tiles

Tiles are immutable, when a function is said to modify a `Tile`, it instead returns a different `Tile` with the required specifications.

For the text tiles, there are some specific functions that apply to text, like `fontsize`, `fontfamily`, `fontcolor` etc., in the [Typography API](http://escher-jl.org/typography-api.html).

For general `Tile` use, like `border`, `bordercolor`, `borderwidth` etc., you can use the [Embellishment API](http://escher-jl.org/embellishment-api.html).

#### 4.2.5. Layouts

##### 4.2.5.1. Basic Layouts

Escher provides primitives like `hbox`, `vbox`, `hskip`, `vskip`, and `flex` for laying out tiles into grids. Complex layouts can be composed from smaller parts. For detailed information, please read the [Guide](http://escher-jl.org/layout-guide.html) and the [Layout API](http://escher-jl.org/layout-api.html).

**Example 9: Basic Layout**
```julia
a,b,c,d = map(fillcolor, ["#837", "#859", "#892", "#875"],
    map(Escher.pad([left, right], 1em), ["A", "B", "C", "D"]))

function main(window)
    x = vbox(a, b, c, d)
    y = vbox(d, c, b, a)

    hbox(x, y)
end
```
`x` and `y` are vertical arrangements of 4 tiles each, these arrangements are themselves put in a `hbox` to place `x` next to `y`.

**Output:**

---------------------------------------------

![Basic Layout Tile Output](https://cloud.githubusercontent.com/assets/25916/15371323/818a7404-1d58-11e6-8c6b-0bec77fdc369.png "Basic Layout Tile")

---------------------------------------------

##### 4.2.5.2. Higher Order Layouts

The [Higher Order Layout API](http://escher-jl.org/layout2-api.html) provides ready-to-use interactive `Tiles` like tabs, pages, menus etc.

**Example 10: Higher Order Layout**
```julia
using Compose, Gadfly, Colors

# define the sierpinski function, see Example 7


function main(window)
    # load assets
    push!(window.assets, "layout2")

    # create the tabs
    tabbar = tabs([
         hbox("Tab 1"),
         hbox("Tab 2"),
         hbox("Tab 3"),

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

**Output:**

---------------------------------------------

![HO Layout Tile Output](http://i.imgur.com/IUP1KLw.gif "Higher Order Layout Tile")

---------------------------------------------


A special case is the [Slideshow API](http://escher-jl.org/slideshow-api.html), used in presentations to create Julia slideshows.

Another useful feature is the `class` function found in the [Utils API](http://escher-jl.org/util-api.html).

#### 4.2.6. Syntax simplification

While it is possible to chain function calls to obtain the desired result, it quickly becomes cumbersome. Fear not, Escher functions have curried methods: omitting the last `Tile` argument to Escher functions returns a 1-argument function that takes a `Tile` argument.

`f(arguments, Tile)` = `f(arguments)(Tile)` = `Tile |> f(arguments)`

For example, `Escher.pad(10mm)` returns an anonymous function of 1 argument which must be a `Tile`, and that returns a new `Tile` with the specified 10mm of padding.
Therefore, `Escher.pad(10mm, txt)` is equivalent to `Escher.pad(10mm)(txt)` or `txt |> Escher.pad(10mm)`. This is helpful when you want to apply, for example, the same padding to a all the tiles in a vector. e.g. `map(Escher.pad(10mm), [tile1, tile2])` will return a vector of two tiles with 10mm padding each.

Moreover, using the curried version with the `|>` infix operator makes for code that reads better.


#### 4.2.7. Interactive UI

**Reactive.jl** package allows "reactive programming" in Julia. Reactive programming is a style of event-driven programming based on signals.  A signal is a change/update in a data value which can also be linked/associated with a UI object/widget, asset, to form a UI Signal which is triggered by event and/or change in state of a UI.  A UI is not required to use the Signal Communication paradigm. A UI Signal is a specific case of Signaling communication, it is a Signal which is associated with a UI Object/Widget. Reactive.jl's [documentation](http://julialang.org/Reactive.jl/) provides an overview of the `Signal` framework. At this point it is highly recommended that you read it. Also, you should read the Escher [Signal API](http://escher-jl.org/signal-api.html).

There are two facets to this rule:
- Getting the input from tiles
- Creating a UI Signal(s) by associating a UI object/widget (asset) with a signal(s)

In practice, the main function might take the form below. We have used two Signals and two Assets to illustrate how they work together.

```julia
function main(window)
    # load "assets" HTML code, for example "widgets" or "tex"
    push!(window.assets, "assets")

    # create signals to hold your assets value, with an initial value
    # Signal can also be typed: Signal{Type}()
    input_signal_1 = Signal("initial_value_1")
    input_signal_2 = Signal("initial_value_2")

    # link the interactive assets to the input signals to create linked assets,
    # for example a `slider` or a `textinput` widget
    linked_asset_1 = subscribe(input_signal_1, asset_1)
    linked_asset_2 = subscribe(input_signal_2, asset_2)

    # create a Signal of UI as a return UI_expression
    # output_signal = Signal(UI_function(input_signal)) = map(UI_function, input_signal)
    # return UI_expression that includes linked widgets and passes input signals as arguments
    # in this example `vbox` was used to group the two assets in one `Tile`, but it can also be `hbox`
    vbox(
      map(linked_asset_1, input_signal_1),
      map(linked_asset_2, input_signal_2)
      )
end
```

Please note that:
- the `map` function can be replaced with the **Do-Block Syntax** and will become:

  ```julia
  map(input_signal) do args
      # function_body
      # return UI_expression that includes linked_widget
  end
  ```
- multiple Signals and normal variables can be used and passed as arguments to the UI_function.
- the UI expression `vbox(map(asset_1, signal_1), map(asset_2, signal_2))` can also be expressed as:

  ```julia
  map(signal_1, signal_2) do args
    vbox(
      asset_1,
      asset_2
    )
  end
  ```
- `args` can be replaced with `_` character, in case you don't need to use the Signal value in the UI. One such example is the Button widget, if the user only requires it to fire an action.


##### 4.2.7.1. Creating a signal of UI using these signals

Some `Tiles` (particularly those that are subtypes of `Behavior` which is in turn a subtype of `Tile`) can write to Reactive's `Signal` signals. Widgets such as sliders, buttons, dropdown menus are subtypes of `Behavior`. The function `subscribe` lets you pipe updates from a behavior into a signal.

**Example 11: Interactive Tiles**
```julia
function main(window)
    # load assets, in this case "widgets"
    push!(window.assets, "widgets")

    # create a Signal which holds the angle at any given time
    iterations = Signal(0)

    # create a Signal of UI as a return UI_expression
    # in this simple case, the liked_signal is passed as a UI_expression
    connected_slider = subscribe(iterations, slider(0:7))
end
```

The `connected_slider` renders as a slider and updates the signal iterations when the slider's knob is moved by the user.

**Output:**

---------------------------------------------

![Interactive Tile 1 Output](https://cloud.githubusercontent.com/assets/25916/15371366/ab7026f6-1d58-11e6-9037-e9107f810e06.png "Interactive Tile 1")

---------------------------------------------

##### 4.2.7.2. Getting the input from tiles

Let's now use the iterations `Signal` to show an interactive Sierpinski's triangle.

**Example 12: Interactive UI**
```julia
using Compose, Colors

# define the sierpinski function, see Example 7


function main(window)
    # Load HTML dependencies related to the slider
    push!(window.assets, "widgets")

     # create a Signal which holds the number of iterations to show
     # the starting value is 5
    iterations = Signal(5)

     # link a widget to the iterations Signal to create a connected_slider
    connected_slider = subscribe(iterations, slider(0:7, value=5))

    # create a Signal of UI as a return UI_expression
    map(iterations) do n
        vbox(
            connected_slider,
            sierpinski(n)
        )
    end
end
```

**Output:**

---------------------------------------------

![Interactive Tile 2 Output](https://cloud.githubusercontent.com/assets/25916/15371377/c032aeec-1d58-11e6-8af9-2017d77a94c3.png "Interactive Tile 2")

---------------------------------------------

##### 4.2.7.3. Interactive Tiles

Escher provides ready-to-use `Tiles` like buttons, input, codemirror etc., in the [Widgets API](http://escher-jl.org/widgets-api.html). Keep in mind that, regular and interactive, `Tiles` can be augmented with clickable, selectable, keypress etc. behavior via the [Behavior API](http://escher-jl.org/behavior-api.html).



### 4.3. Escher Advanced

This section is intended to provide a more detailed view on the way Escher works and how to create your own custom Tiles.

#### 4.3.1. Custom Tiles

I can think of three reasons why one might need to create custom Tiles, for fun not included:

- if the current APIs do not provide the elements you require, you can build your own.
- Escher may not give access to all available properties defined in the HTML element, or it may have certain default values that you would like to change.
- you might want to optimize your code. When loading assets, all templates in the assets package get loaded into the webpage, even the ones that are not used. For the development phase this is not an issue, but in production you might want to provide a faster loading time by creating your package only with the templates you are using.

To create a new custom `Tile` you need three things:

1. a [custom HTML element](http://www.html5rocks.com/en/tutorials/webcomponents/customelements/) you wish to use
2. a `Tile` which corresponds to the custom element. The `Tile` fields do not necessarily mirror the properties of the HTML.
3. a `render(::myTile, state)` which returns an [Elem](https://github.com/shashi/Patchwork.jl#creating-elements), which in turn creates the the same custom HTML element mentioned in step 1.

These three requirements are placed in two different files:

1. `assets/<asset-name>.html` is where you place the HTML code
2. `src/library/<asset-name>.jl` holds the custom `Tile` and the `render` definition

Assets files, both `.html` and `.jl`, can contain multiple custom element definitions.

For usage, the `<asset-name>.html` is pushed to the browser from the `main` function inside your Julia Escher UI file: `push!(window.assets, "asset-name")`.

On the other hand, `<asset-name>.jl` must be imported in the `src/Escher.jl` file: `include("library/<asset-name>.jl")`. A restart of Escher server is necessary in order to recompile with the new addition.


#### 4.3.2. HTML code

This section is intended to show how to use custom HTML elements, not to create ones. For creating HTML elements please see the [Polymer guide](https://www.polymer-project.org/1.0/docs/start/first-element/intro.html).

##### 4.3.2.1. Custom HTML elements format

The format for custom element templates is shown below. The custom element name is `custom-element`. All custom elements must have multi-word names, separated by the "-" (dash) character. This code does not render, it is only a template /definition, like a Julia function definition, in this regard.

``` html
<dom-module id="custom-element">
    <template>
        <style>
            /* local styles go here */
            :host {
                display: inline-block;
            }
        </style>

        <!-- local DOM goes here -->

    </template>

    <script>
        /* the Polymer script registers the element */
        Polymer({
            /* this is the element's prototype */
            is: 'custom-element'
        });
    </script>
</dom-module>
```

Usually the template code is kept in a separate file, `<custom-element>.html` and imported into the main file using the `link rel="import"` element.

``` html
<link rel="import" href="<templates-folder>/<custom-element>.html">
```


##### 4.3.2.2. Custom HTML elements sets

Multiple elements may be grouped in a set or `<templates-file>.html`.

``` html
<link rel="import" href="<templates-folder>/<custom-element-1>.html">
<link rel="import" href="<templates-folder>/<custom-element-2>.html">
<link rel="import" href="<templates-folder>/<custom-element-3>.html">
<link rel="import" href="<templates-folder>/<custom-element-4>.html">
```

The templates file is imported in similar fashion to the custom element import:

``` html
<link rel="import" href="<templates-folder>/<templates-file>.html">
```


##### 4.3.2.3. Escher custom HTML elements library

Escher makes use of some of the [Polymer Library](https://elements.polymer-project.org/) elements. The Polymer library is installed and managed by [bower](http://bower.io/). It is stored locally in `assets/bower_components/`, so references are made with relative path:

``` html
<link rel="import" href="bower_components/<templates-folder>/<templates-file>.html">
```

Using the Polymer Library has some advantages: you do not need to tinker with the HTML /JS code, each provided element has an exposed API and you only need to address the properties /methods /events you are interested in, provided that it is enough to have a functional element.


##### 4.3.2.4. The content of the asset .html file

In conclusion, inside your `assets/<asset-name>.html` file, depending on your needs, you might have one of these choices:

1. a one element definition of the custom HTML element, like the [assets/tex.html](./assets/tex.html).
2. a list of one element imports of the custom HTML element, like the [assets/widgets.html](./assets/widgets.html)
3. a list of one or more one element or sets imports, like the [assets/icons.html](./assets/icons.html).



#### 4.3.3. Julia code

For each template, we need to create a `Tile` definition, plus methods, and the corresponding `render` method. They are both placed in the same file, one after the other.


##### 4.3.3.1. Creating new `Tile` types

The `Tile` type in Julia is created using the `@api` macro. This lets Escher use a high-level DSL for defining the API for a `Tile` type. Think of it as defining methods for the constructors of the type with a system more powerful than plain dispatch definitions.

Here is the syntax of `@api`:

``` julia
@api <constructor_name> => (<TypeName>  <: Tile) begin
  doc(md"<documentation string>")
  <arg_specifics> # one or more
end
```

This expression generates a type whose name is `<TypeName>`, while the constructor itself will be named `<constructor_name>`. The convention in Escher is to use lower cased names for the actual constructors and CamelCased names for the types.

A `doc(md"<doc string>")` expression defines the documentation of a Tile constructor. The `<arg_specifics>` takes a keyword argument `doc=""` which can define the documentation of each argument (e.g. `arg(color::Color, doc="border color.")`. This is what gets used while generating the API documentation at [escher-jl.org](http://escher-jl.org/).


The fields are defined by one or more `<arg_specifics>`. The annotation also includes information about how the filed works. The type of arguments are as follows:

- `arg(x::SomeType)`
  - **it becomes** `x::Any` in all method signatures, argument will be converted to `SomeType` before construction.
  - **it means** for the caller that it's a normal argument. the value gets converted to the right type if it can be.
- `arg(x::SomeType=default_value)`
  - **results** in two kinds of method signatures, one with `x::Any`, argument will be converted to `SomeType` before construction; the other is without `x` in the list of arguments, the constructor then uses the default value in its place.
  - **it means** the argument is not required, if it's missing the default value is used. It's similar to Julia's trailing optional arguments, but it can appear in the beginning of an argument list too.
- `kwarg(x::SomeType=default_value)`
  - **it becomes** `x=default_value` (kwarg) in all method definitions, argument will be converted to `SomeType`.
  - **it means** it's a regular old keyword argument. the value gets converted to the right type if it can be.
- `typedarg(x::SomeType)`
  - **becomes** `x::SomeType` in all method signatures
  - **it means** the argument is required and must be a `SubType` instance.
- `typedarg(x::SomeType=default_value)`
  - **results** in two kinds of method signatures, one with `x::SomeType`; the other without `x` in the list of arguments, the constructor then uses the default value in its place.
- `typedkwarg(x::SomeType=default_value)`
  - **becomes** `x::SomeType=default_value` (kwarg) in all method definitions.
  - **means** a keyword argument which must be a `SomeType` instance
- `curry(x::SomeType)`
  - **results** in the creation of two kinds of methods. One which has the argument `x::SomeType` in its signature, another that does not have an argument in its place. The latter method returns a lambda that takes x and calls the former method to actually construct the type.
  - **means** if this argument is missing, then you get back a lambda which you can call with the missing argument. Usually only the last non-keyword argument, if any, is created with curry. This makes `|>` convenient to use in many cases. This argument encourages a free-flowing experimental style. You can more easily write `<a long expression> |> x` than `x(<a long expression>)`, handy while playing with changes, sometimes `|>` reads better.

**Example 13: @api macro usage**

``` julia
@api border => (Bordered <: Tile) begin
    arg(side::Side)
    curry(tile::Tile)
    kwarg(color::Color=colorant"black")
    typedkwarg(thickness::Length=1pt)
end
```

**Generated definitions**

---------------------------------------------

``` julia
border(side::Any, tile::Any; color=colorant"black", thickness::Length=1pt) = Bordered(side, convert(Tile, tile), convert(Color, color), thickness)
border(side::Any; color=colorant"black", thickness::Length=1pt) = tile -> Bordered(side, tile, convert(Color, color), thickness)
```

---------------------------------------------

The `Tile` argument is the object that will be getting the border in this case. This is a general style in Julia, you construct new tiles to endow some property to an input tile.

The user can call it in two different ways:

``` julia
border(side, tile, color=my_color, thickness=2pt)
tile |> border(side, color=my_color, thickness=2pt)
```

**Example 14: @api macro usage**

``` julia
@api border => (Bordered <: Tile) begin
    arg(style::BorderStyle)
    typedarg(side::Array{Sides}=[left,right,top,bottom])
    curry(tile::Tile)
    kwarg(color::Color=colorant"black")
end
```


**Generated definitions**

---------------------------------------------

``` julia
border(style::Any, side::Array{Side}, tile::Any; color=colorant"black", thickness::Length=1pt) =
    Bordered(convert(BorderStyle, style), side, convert(Tile, tile), convert(Color, color), thickness)

border(style::Any; color=colorant"black", thickness::Length=1pt) =
    Bordered(convert(BorderStyle, style), [left,right,top,bottom], tile, convert(Color, color), thickness)

border(style::Any, side::Array{Side}; color=colorant"black", thickness::Length=1pt) =
    Bordered(convert(BorderStyle, style), side, tile, convert(Color, color), thickness)

border(style::Any; color=colorant"black", thickness::Length=1pt) =
    tile -> Bordered(convert(BorderStyle, style), [left,right,top,bottom], tile, convert(Color, color), thickness)
```

---------------------------------------------

The user can call it in two different ways:

``` julia
border(dotted, [left], tile, color=colorant"blue") # => Bordered(Dotted(), [Left()], FooTile(), RGB(...))
tile |> border(dotted, [left], color=colorant"red") # => Bordered(Dotted(), [Left()], FooTile(), RGB(...))
border(dotted, tile, color=colorant"red")  # => Bordered(Dotted(), [Left(),Right(),Top(),Bottom()], FooTile(), RGB(...))
tile |> border(dotted, color=colorant"red") # => Bordered(Dotted(), [Left(),Right(),Top(),Bottom()], FooTile(), RGB(...))
```

Type parameters can be used in `@api` definitions, for example:

``` julia
@api border => (Bordered{T <: Side} <: Tile) begin
    arg(side::T)
    curry(tile::Tile)
    kwarg(color::Color=colorant"black")
end
```

##### 4.3.3.2. The `render` method

The connection between the Escher `Tile`, and the browser is done using the `render` method. A `Tile` is rendered into a [Patchwork.jl](https://github.com/shashi/Patchwork.jl) `Elem` type and placed in the Virtual DOM.

The general format is as follow, but for detailed information please read the Patchwork.jl [documentation](https://github.com/shashi/Patchwork.jl#creating-elements):

``` julia
render(e::TypeName, state) = Elem("custom-element", attributes = Dict(:htmlPropertyOne => e.fieldOne, :htmlPropertyTwo => e.fieldTwo))
```

The `state` object gets passed around when a `Tile` renders other tiles contained by it. It's just a plain dictionary, so the render methods can decide what to use it for.

#### 4.3.4. Real life use

- create custom `Tiles` with behavior, what are the ways to interact with HTML template's methods and events APIs
- provide step-by-step example for creating assets
