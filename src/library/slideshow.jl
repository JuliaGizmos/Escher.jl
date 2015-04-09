export slideshow

@api slideshow => SlideShow <: Tile begin
    curry(tiles::TileList)
    kwarg(selected::Int=0)
    kwarg(transitions::AbstractArray=["slide-from-right", "cross-fade-all"])
end

render_slide(x) =
    packitems(center, packacross(center, vbox([x]))) |>
        (t -> render(t) & [:attributes => [:fit => :fit]])

render(x::SlideShow) =
    Elem("slide-show", map(render_slide, x.tiles.tiles))
