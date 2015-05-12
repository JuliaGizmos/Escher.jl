export slideshow

@api slideshow => SlideShow <: Selection begin
    curry(tiles::TileList)
    kwarg(selected::Int=0)
    kwarg(transitions::String="slide-from-right cross-fade-all")
end

render_slide(x) =
    packitems(center, packacross(center, vbox([x]))) |>
        (t -> render(t) & @d(:attributes => @d(:fit => :fit)))

render(x::SlideShow) =
    Elem("slide-show", map(render_slide, x.tiles.tiles),
        transitions=x.transitions)
