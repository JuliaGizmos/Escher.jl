export slideshow

@api slideshow => SlideShow <: Selection begin
    curry(tiles::TileList)
    kwarg(selected::Int=0)
    kwarg(transitions::String="slide-from-right cross-fade-all")
end

render_slide(x, state) =
    packitems(center, packacross(center, vbox([x]))) |>
        (t -> render(t, state) & @d(:attributes => @d(:fit => :fit)))

render(x::SlideShow, state) =
    Elem("slide-show", map(x -> render_slide(x, state), x.tiles.tiles),
        transitions=x.transitions)
