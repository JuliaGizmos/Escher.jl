export list, image, link, abbr

@api list => List <: Tile begin
    curry(tiles::AbstractArray)
    kwarg(ordered::Bool=false)
end

render(l::List) =
    Elem(l.ordered ? :ol : :ul,
         map(x -> Elem(:li, render(x)), l.tiles))

@api image => Image <: Tile begin
    arg(url::String)
    kwarg(alt::String="")
end

render(i::Image) =
    Elem(:div, Elem(:img, src=i.url, alt=i.alt))

@api link => Hyperlink <: Tile begin
    arg(url::String)
    curry(tiles::TileList)
end

render(a::Hyperlink) =
    Elem(:a, render(a.tiles), href=a.url)

@api abbr => Abbr <: Tile begin
    arg(title::String)
    arg(tiles::TileList)
end

render(a::Abbr) =
    Elem(:abbr, render(a.tiles), title=a.title)
