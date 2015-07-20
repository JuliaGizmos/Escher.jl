export slideshow, slide, fragment

@api slideshow => SlideShow <: Selection begin
    curry(tiles::TileList)
    kwarg(selected::Int=0)
end

render_slide(x, state) =
    packitems(center, packacross(center, vbox([x]))) |>
        (t -> render(t, state) & @d(:attributes => @d(:fit => :fit)))

@api slide => Slide <: Tile begin
    arg(tile::Tile)
    kwarg(transitions::String="slide-from-right cross-fade-all")
end

@api fragment => Fragment <: Tile begin
    typedarg(index::Int=0)
    curry(tile::Tile)
end

render(f::Fragment, state) =
    Elem("slide-fragment", render(f.tile, state),
        index=f.index)

render(s::Slide, state) =
    Elem("slide-tile", render(s.tile, state)) & @d(
        "inTransitions" => s.transitions)

wrapslide(s::Slide) = s
wrapslide(s) = slide(s)

render(x::SlideShow, state) =
    Elem("slide-show",
        map(x -> render(wrapslide(x), state), x.tiles.tiles))

