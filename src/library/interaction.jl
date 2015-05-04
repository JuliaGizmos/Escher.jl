immutable Resizable <: Behavior
    name::Symbol
    tile::Tile
end

immutable Size
    proportions::(Float64, Float64)
end

resizable(tile, container; name=:_size) = Resizable(name, tile, container)

immutable Draggable <: Behavior
    name::Symbol
    tile::Tile
    container::Tile
end

draggable(tile, container; name=:_drag) = Draggable(name, tile, container)

immutable Drag
    fraction::(Float64, Float64)
end

immutable Sortable <: Behavior
    name::Symbol
    tile::AbstractArray
end

immutable PositionSwap
    swap::(Int, Int)
end

