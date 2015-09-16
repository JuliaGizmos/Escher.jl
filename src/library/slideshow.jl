export slideshow, slide, fragment

@api slideshow => (SlideShow <: Selection) begin
    doc("A slideshow.")
    curry(tiles::TileList, doc="An array of slides.")
    kwarg(selected::Int=1, doc="Index of the current slide.")
end

render_slide(x, state) =
    packitems(center, packacross(center, vbox([x]))) |>
        (t -> render(t, state) & @d(:attributes => @d(:fit => :fit)))

@api slide => (Slide <: Tile) begin
    doc("A slide. Content of the slide is centered vertically and horizontally.")
    curry(tile::Tile, doc="Content of the slide.")
    kwarg(
        transitions::AbstractString="slide-from-right cross-fade-all",
        doc=md"""A space-separated list of transitions to use for the current
                slide. Valid transitions are `"cross-fade"`,
                `"hero-transition"`,`"list-cascade"`, `"scale-up"`,
                `"slide-down"`, `"slide-from-bottom"`,`"slide-from-right"`,
                `"slide-up"` and `"tile-cascade"`."""
        )
end

@api fragment => (Fragment <: Tile) begin
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
        map(x -> render(wrapslide(x), state), x.tiles.tiles),
        selected=x.selected-1
    )
