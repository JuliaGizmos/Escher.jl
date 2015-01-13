# Paper elements
immutable Paper{elem} <: Tile
    attributes::Dict
end

paper(elem; attrs...) = Paper{elem}(Dict(attrs))

slider(range::Range) =
    paper(:slider, max=last(range), min=first(range), step=step(range))
