export list, image, link, abbr

@api list => List <: Tile begin
    curry(tiles::TileList)
    kwarg(ordered::Bool=false)
end

render(l::List, state) =
    Elem(l.ordered ? :ol : :ul,
         map(x -> Elem(:li, render(x, state)), l.tiles.tiles))

@api image => Image <: Tile begin
    arg(url::String)
    kwarg(alt::String="")
end

render(i::Image, state) =
    Elem(:img, src=i.url, alt=i.alt, style=@d("width"=>"auto", "height"=>"auto", "display" => "block"))

@api link => Hyperlink <: Tile begin
    arg(url::String)
    curry(tiles::TileList)
end

render(a::Hyperlink, state) =
    Elem(:a, render(a.tiles, state), href=a.url)

@api abbr => Abbr <: Tile begin
    arg(title::String)
    curry(tiles::TileList)
end

render(a::Abbr, state) =
    Elem(:abbr, render(a.tiles, state), title=a.title)
