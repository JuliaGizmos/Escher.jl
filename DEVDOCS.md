Developer Docs
==============

## The Basics

Code contained in the `basics/` directory involves code required to bootstrap Escher.

Firstly, it contains the definition of the Tile abstract type of which all renderable objects in Escher are subtypes. A Tile has the contract that it has a `render(tile, state)` method that produces a `Patchwork.Elem` object which represents its DOM rendition. This is the exact datastructure that gets replicated in the browser. The `state` object gets passed around when a Tile renders other tiles contained by it. It's just a plain dictionary, so the `render` methods can decide what to use it for.

As user of Escher goes around creating `Tile` or `Signal{T<:Tile}` objects. A "Signal of Tiles" gets rendered as a changing UI by the Escher server mechanism that is described in a later section. You can construct these signals using input signals from various sources, which are discussed in the "Interaction" subsection.


Tile is the common currency which is used by all functionality in Escher. There are many functions in Escher which you can use to generate tiles from other Julia values (e.g. primitive types, DataFrames, plots), while the rest of the functions take Tiles as arguments and return either a modified version of the input (commonly when there is only one input), or a combined arrangement of the inputs (commonly in the case of multiple tiles being input). One could say that the Tile type forms a closure under these library functions.

### The `@api` macro

The `@api` macro lets Escher use a high-level DSL for defining the API for a Tile type. Think of it as defining methods for the constructors of the type with a system more powerful than plain dispatch definitions. Here is the syntax of `@api`:

```julia
@api <constructor_name> => (<TypeName>  <: Tile) begin
  doc(md"<documentation string>")
  <arg_specifics> # one or more
end
```

This expression generates a type whose name is `<TypeName>`, while the constructor itself will be named `<constructor_name>`. The convention in Escher is to use lower cased names for the actual constructors and CamelCased names for the types.

The fields are defined by one or more `<arg_specifics>`. The annotation also includes information about how the filed figures as an arguement in the constructor. `<arg_specifics>` can be one of:

- `arg(x::SomeType)`
  - **it becomes:** `x::Any` in all method signatures, argument will be converted to `SomeType` before construction.
  - **what it means for the caller:** it's a normal argument. the value gets converted to the right type if it can be.
- `arg(x::SomeType=default_value)`
  - **results in** two kinds of method signatures, one with `x::Any`, argument will be converted to `SomeType` before construction; the other is without `x` in the list of arguments, the constructor then uses the default value in its place.
  - **it means** the argument is not required, if it's missing the default value is used. It's similar to Julia's trailing optional arguments, but it can appear in the beginning of an argument list too.
- `kwarg(x::SomeType=default_value)`
  - **it becomes**  `x=default_value` (kwarg) in all method definitions, argument will be converted to `SomeType`.
  - **it means** it's a regular old keyword argument. the value gets converted to the right type if it can be.
- `typedarg(x::SomeType)`:
   - **becomes** `x::SomeType` in all method signatures
   - **it means** the argument is required and must be a `SubType` instance.
- `typedarg(x::SomeType=default_value)`
   - **results in** two kinds of method signatures, one with `x::SomeType`; the other without `x` in the list of arguments, the constructor then uses the default value in its place.
- `typedkwarg(x::SomeType=default_value)`
   - **becomes** `x::SomeType=default_value` (kwarg) in all method definitions.
   - **means** a keyword argument which must be a `SomeType` instance
- `curry(x::SomeType)`
   - **results in** the creation of two kinds of methods. One which has the argument `x::SomeType` in its signature, another that does not have an argument in its place. The latter method returns a lambda that takes `x` and calls the former method to actually construct the type.
   - **means** if this argument is missing, then you get back a lambda which you can call with the missing argument. Usually only the last non-keyword argument, if any, is created with `curry`. This makes `|>` convenient to use in many cases. This argument encourages a free-flowing experimental style. You can more easily write `<a long expression> |> x` than `x(<a long expression>)`, handy while playing with changes, sometimes `|>` reads better.

For example:

```julia
@api border => (Bordered <: Tile) begin
    arg(side::Side)
    curry(tile::Tile)
    kwarg(color::Color=colorant"black")
    typedkwarg(thickness::Length=1pt)
end
```

will generate the definitions:

```julia
border(side::Any, tile::Any; color=colorant"black", thickness::Length=1pt) = Bordered(side, convert(Tile, tile), convert(Color, color), thickness)
border(side::Any; color=colorant"black", thickness::Length=1pt) = tile -> Bordered(side, tile, convert(Color, color), thickness)
```

The `tile` argument is the object that will be getting the border in this case. This is a general style in Julia, you construct new tiles to endow some property to an input tile.

The user can call it in two different ways.

```julia
border(side, tile, color=my_color, thickness=2pt)
tile |> border(side, color=my_color, thickness=2pt)
```

Let's complicate this API a bit more with a `typedarg`:

```julia
@api border => (Bordered <: Tile) begin
    arg(style::BorderStyle)
    typedarg(side::Array{Sides}=[left,right,top,bottom])
    curry(tile::Tile)
    kwarg(color::Color=colorant"black")
end
```

Generates:

```julia
border(style::Any, side::Array{Side}, tile::Any; color=colorant"black", thickness::Length=1pt) =
  Bordered(convert(BorderStyle, style), side, convert(Tile, tile), convert(Color, color), thickness)

border(style::Any; color=colorant"black", thickness::Length=1pt) =
  Bordered(convert(BorderStyle, style), [left,right,top,bottom], tile, convert(Color, color), thickness)

border(style::Any, side::Array{Side}; color=colorant"black", thickness::Length=1pt) =
   Bordered(convert(BorderStyle, style), side, tile, convert(Color, color), thickness)

border(style::Any; color=colorant"black", thickness::Length=1pt) =
  tile -> Bordered(convert(BorderStyle, style), [left,right,top,bottom], tile, convert(Color, color), thickness)

```

So the possible invocations are:

```julia
border(dotted, [left], tile, color=colorant"blue") # => Bordered(Dotted(), [Left()], FooTile(), RGB(...))
tile |> border(dotted, [left], color=colorant"red") # => Bordered(Dotted(), [Left()], FooTile(), RGB(...))
border(dotted, tile, color=colorant"red")  # => Bordered(Dotted(), [Left(),Right(),Top(),Bottom()], FooTile(), RGB(...))
tile |> border(dotted, color=colorant"red") # => Bordered(Dotted(), [Left(),Right(),Top(),Bottom()], FooTile(), RGB(...))
```

Type parameters can be involved in `@api` definitions, for example.

```julia
@api border => (Bordered{T <: Side} <: Tile) begin
    arg(side::T)
    curry(tile::Tile)
    kwarg(color::Color=colorant"black")
end
```

**Documenting with `@api`**

A `doc(md"<doc string>")` expression defines the documentation of a Tile constructor. The arg pecs take a keyword argument `doc=""` which can define the documentation of each argument (e.g. `arg(color::Color, doc="border color.")`. This is what gets used while generating the API documentation at escher-jl.org.

## Browser-side code

When you launch an Escher UI, the code goes through a series of transformations.

```
Julia code -execute-> Tile object -render-> Patchwork Elem object -format-> JSON -applyPatch-> DOM
```

The UI starts out as a `Tile` object, then gets converted to a Patchwork `Elem` object which is sent over the network to the browser as JSON where it gets rendered as the DOM. DOM stands for [Document Object Model](https://en.wikipedia.org/wiki/Document_Object_Model), it's a convention in which a web page is represented as a datastructure by the browser. Any modifications to this data structure results in modification to some aspect of the rendered output - it could change a style property (CSS properties of an element are also manifest in its DOM), it could change its contents, or some property specific to the HTML element.

When a `Tile` is rendered, it can only generate Patchwork `Elem` objects, in other words they can produce only HTML elements. This might seem limiting at first, for example to make an element clickable and listen to its events you need more than just HTML, you need to set up an event handler, a web socket / XHR request. This would be true a few years ago. You'd have to generate bespoke JS to deal with specific kinds of features you would like to add to plain HTML elements. However, with the advent of the Web Components specification, this is no longer true. The key facility of the Web Components spec is it gives developers the ability to create their own [custom HTML elements](http://www.html5rocks.com/en/tutorials/webcomponents/customelements/) which can have pre-defined behavior which can interact with its parent / sibling / child elements.

Escher uses a bunch of custom HTML elements as well as an off-the-shelf library of elements called [Polymer](https://www.polymer-project.org/1.0/). Below is an overview of what's inside the `assets/` folder in Escher.

- `basics.html`: this file is imported by every Escher page implicitly. It loads Polymer, `escherd.html`, `signals.html`, `behavior.html` and the default stylesheets, in that order.
- `escherd.html`
  - it defines the `Escher` object in JavaScript which acts like a namespace for Escher functionality in the browser
  - it also defines `EscherMixins.LifeCycle` polymer mixin, which is used by most of the other Escher elements. The main purpose of this mixin is to work around element-load event issues. Using this mixin allows custom elements to use the `domInit` method to define what happens when an element gets rendered on screen.
  - it sets up an event listener for `signal-transport` events. `signal-transport` events are fired by Escher whenever some piece of data needs to be sent over to the Escher server to update a Reactive signal. The default event handler uses `Escher.send` to send the information, this itself is defined based on the existence of Blink or not so as to use the more appropriate channels for communication.
   - this file also has the definition of `signal-container` HTML custom element, which is used to render a signal of escher UIs. Every Escher page contains a `<signal-container signal-id="root"></signal-container>` element, which is where the UI gets rendered.
- `signals.html`: the elements here correspond to those rendered by `basics/signal.jl` `signal-transport` element, which is used to annotate that another element would like to send some events to the server, is defined here for example.
  - it also defines `EscherMixins.ReactiveSignal` mixin, which is going to be used by all other elements that want to be able to communicate with the server.
- `behavior.html`: this file contains custom elements used to set up the most basic event handlers, such as `clickable-behavior`, `keypress-behavior`, `watch-state` (fired when some attribute of the parent changes). These correspond to elements rendered by the API in `basics/behavior.jl`
- `bower_components`: contains third party custom element libraries (including polymer). The dependencies are listed in `bower.json` file.
- `*.html`: if `X.html` is present in the `assets/` directory, the user can call `push!(window.assets, "X")` to load that file as an HTML import. This is how we manage dependencies which are not always required (widgets.html, codemirror.html, tex.html etc.)

For more on how to create a Polymer element (highly recommended) [go here](https://www.polymer-project.org/1.0/docs/start/first-element/intro.html)

To sum up, to create your own new Tile type which does something special, you need:

1. a custom HTML element with the right attributes to represent input to your Tile type, the inputs should have proper handling of changes to them.
2. a `Tile` type, generally using the `@api` macro
3. A `render` method for the above type of tile which emits the `Elem` of the element defined in step 1.

### Example of binding a JS library: KaTeX

To illustrate the typical workflow in binding a JS library, we will consider the LaTeX typesetting functionality provided by Escher.

We start by looking at `assets/tex.html`. It starts off by including the [KaTeX](https://khan.github.io/KaTeX/) javascript library for LaTeX typesetting.

```html
<script src="bower_components/katex/build/katex.js"></script>
```

Notice that the path is relative. The library itself is installed and managed by [bower](http://bower.io/). The convention is to just commit the dependencies in Escher, so as to provide a works-out-of-the-box experience.

The rest of the file defines the `<ka-tex>` custom element.
```
<dom-module
    id="ka-tex" >

...
</dom-module>
```

For more on how to create a custom element [see this guide](https://www.polymer-project.org/1.0/docs/start/first-element/intro.html)

This custom element has two properties: `source` and `block`.

`source` is a string property which is set to the LaTeX code to be rendered, while `block` is a boolean property which denotes whether the rendered output should look like a block (nothing else around it) or inline (free-flowing with other content).

The `_sourceChanged` and `_blockChanged` event handlers defined for changes to `source` and `block` properties. It re-renders the typeset output when one of the properties changes. This is essential as Escher might patch any of these attributes when it needs to update the UI.

**On the Julia side**

The Julia code related to the LaTeX functionality is defined in `src/library/tex.jl`. The main API is:

```julia
@api tex => (TeX <: Tile) begin
    doc("Show TeX/LaTeX.")
    arg(source::AbstractString, doc="The source TeX code.")
    kwarg(
        block::Bool=false,
        doc="""If set to true, the resulting tile will be a block. It is inline
             by default"""
    )
end
```

A valid invocation of this api is:

`tex("my latex here", block=true)`, this produces the `TeX` tile type. The type is rendered by Escher using the `render` method, which goes like this:


```julia
render(l::TeX, state) =
    Elem("ka-tex", attributes=@d(:source=>l.source, :block=>boolattr(l.block)))
```

it creates the `ka-tex` element and sets the `source` and `block` attributes. Notice that the `block` attribute is set to `boolattr(l.block)` instead of just `l.block`. This is because of some subtleties in rendering boolean attributes, a boolean attribute should be set to `nothing` if it's false, or a string (any string) otherwise, `boolattr` takes care of this.
