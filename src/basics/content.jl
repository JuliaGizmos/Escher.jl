export list, image, link, abbr

@api list => (List <: Tile) begin
    doc("Stylize a list of tiles as an itemized list.")
    curry(tiles::TileList , doc="A tile or a vector of tiles.")
    kwarg(ordered::Bool=false, doc=md"If set to `true`, numbering will be used.")
end

render(l::List, state) =
    Elem(l.ordered ? :ol : :ul,
         map(x -> Elem(:li, render(x, state)), l.tiles.tiles))

@api image => (Image <: Tile) begin
    doc(md"""Show an image from a `url`. To read an image and display it, use
             [`Images.imread`](https://github.com/timholy/Images.jl#readme).""")
    arg(url::AbstractString, doc="The url of the image.")
    kwarg(alt::AbstractString="", doc="Text to display if image does not load.")
end

render(i::Image, state) =
    Elem(:img, src=i.url, alt=i.alt, style=@d("width"=>"auto", "height"=>"auto", "display" => "block"))

@api link => (Hyperlink <: Tile) begin
    doc("A hyperlink.")
    arg(url::AbstractString, doc="The destination of the link.")
    curry(
        tiles::TileList,
        doc="""A tile or a vector of tiles. These tiles link to the url."""
    )
end

render(a::Hyperlink, state) =
    Elem(:a, render(a.tiles, state), href=a.url)

@api abbr => (Abbr <: Tile) begin
    doc(md"""An abbreviation. When you hover over an abbreviation, the `title` is
          shown in a tooltip.""")
    arg(title::AbstractString, doc="The title to show.")
    curry(
        tiles::TileList,
        doc="A tile or a vector of tiles. Hovering over these tiles triggers the tooltip."
    )
end

render(a::Abbr, state) =
    Elem(:abbr, render(a.tiles, state), title=a.title)
