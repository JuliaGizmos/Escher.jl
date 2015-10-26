# Adding a new Escher element

Escher relies heavily on the [Polymer project](https://www.polymer-project.org/1.0/) for client-side elements. Not all elements are included in the project, and it is possible to create new Polymer elements, but for the purposes of this tutorial, I will pick one from the [catalog](https://elements.polymer-project.org/).

## Assets

Asset files are served to the client, and are included in pages. On Unix-like OSes, you can find them in *~/.julia/v0.4/Escher/assets*, which contains *.html* files, styling sheets, and *bower_components*. To install a new component, you must run `bower install --save PolymerElements/<elementName>`. From the catalog, the command should be available from the drawer on the left. In this case, we are using [paper-drawer-panel](https://elements.polymer-project.org/elements/paper-drawer-panel), a menu panel that steps out of the way when window or screen real estate is limited.

Any new assets need to be imported into an HTML file from which they will be served from Escher. The recommended way to do this is to add an assets folder to the relevant Julia package ([Package Development](http://docs.julialang.org/en/release-0.4/manual/packages/#package-development)), and to serve the asset with `push!(window.assets, (<Pkg name>, <asset name>))`, but if you are contributing to Escher itself,  you would `push!(window.assets, <asset name>)`.

## API generation

Escher makes much use of [subtyping](https://en.wikipedia.org/wiki/Subtyping) (interface inheritance) in Julia, and most Escher elements are subtypes of the abstract type Tile. To facilitate development, we use macros to generate immutable types and curried constructor methods. The `@api` macro.

```julia
@api border => (Bordered{T <: Side} <: Tile) begin
  arg(side::T)
  curry(tile::Tile)
  kwarg(color::Color=colorant"black")
end
```
    
  Should result in:

```julia
immutable Bordered{T <: Side} <: Tile
   tile::Tile
   color::Color
end
border(side, tiles; color::Color=colorant"black") = Bordered(side, tiles, color)
border(side; kwargs...) = tiles -> border(side, tiles; kwargs...)
```

Note how the 2nd constructor method of border takes only 1 argument, and creates an anonymous function that takes the second argument `tile`. This is called currying and may more accurately be referred to as partial application, and is useful when we want to use a higher-order function such as `map` or when we want to chain functions e.g. `(md"Text Here" |> pad(3em) |> fillcolor("red")` instead of `fillcolor("red",pad(3em,md"Text Here") )` 

In the case of a Polymer paper-drawer-panel, we want our type to contain a tile for a side drawer, and one for the main menu. We may also want to make an optional button to bring back the menu.  

```julia
@api drawer => (Drawer <: Tile) begin
    doc("A side drawer panel that steps out of the way in a narrow layout.")
    arg(
        drawer::Tile,
        doc="drawer"
    )
    curry(tile::Tile, doc="contents")
    kwarg(
        menuButton::Bool=true,
        doc="Include a menu button to toggle. If false, you may want to set a custom button by adding an element with a custom attribute paper-drawer-toggle"
    )
end
```

When we are done, we need to ensure that what the constructors are exported, so in whatever file we're editing, you need to make sure it exports our method (`export drawer` in this case)

When `using Escher` as would be the case when creating elements in an external Package, non-exported methods and macros need absolute paths e.g. `Escher.@api`.

## Rendering

Escher elements must be delivered to a browser at some point, so it needs to be converted into a virtual DOM which is rendered into HTML. In doing so, we need to create the WebComponent elements that Polymer listens for. Escher uses [Patchwork](https://github.com/shashi/Patchwork.jl) for virtual DOM manipulation and diffing, so when constructing a node tree, refer to this documentation. To know what we are constructing, we need to refer to the Polymer documentation for [paper-drawer-panel](https://elements.polymer-project.org/elements/paper-drawer-panel), which at the simplest level would look something like:

```html
<paper-drawer-panel>
  <div drawer>
    <paper-button paper-drawer-toggle>
      ≡
    </paper-button>
    Drawer panel...
  </div>
  <div main> Main panel... </div>
</paper-drawer-panel>
```

Our render method must place contents of *drawer* in "Drawer panel..." and *tile* in "Main panel". It also needs to conditionally place a toggle Button depending on the value of *menuButton*.

```julia
render(paperDrawer::Drawer, state) = begin
    Elem("paper-drawer-panel", id="paperDrawerPanel",
        [
            Elem("div",attributes = @d(:drawer=>""), render(paperDrawer.drawer,state)),
            Elem("div",attributes = @d(:main=>""),
                if paperDrawer.menuButton
                    drawerToggleButton = Elem("paper-button",attributes = @d("paper-drawer-toggle"=>""),"≡")
                    [ drawerToggleButton, render(paperDrawer.tile,state) ]
                else
                    render(paperDrawer.tile,state)
                end
            )
        ]
    )
end
```

Some things to note:

* Utility functions and macros from Escher such as *@d* which makes a dictionary (more can be found in *~/.julia/v0.4/Escher/src/basics/util.jl* or *~/.julia/v0.4/Escher/src/basics/macros.jl* )
* Patchwork supports a variety of styles: it can take attributes as keyword arguments or as an explicit keyword argument of type *Dict*
* Elements can have Lists of elements as children, or a single element as a child.
