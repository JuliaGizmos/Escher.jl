@api list => List <: Tile begin
    curry(tiles::AbstractArray)
    kwarg(ordered::Bool=false)
end

render(l::List) =
    Elem(l.ordered ? :ol : :ul,
         map(x -> Elem(:li, render(x)), l.tiles))

@api img => Image <: Tile begin
    arg(url::String)
    kwarg(alt::String=nothing)
end

render(i::Image) =
    Elem(:img, src=i.url, alt=i.alt)

@api link => Hyperlink <: Tile begin
    arg(url::String)
    curry(tile::Tile)
end

render(a::Hyperlink) =
    Elem(:a, render(tile), href=a.url)
