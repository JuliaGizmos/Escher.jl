export resizable,
       draggable,
       sortable

@api resizable => Resizable <: Behavior begin
    arg(tile::Tile)
    kwarg(name::Symbol=:_resizer)
end

render(r::Resizable) =
    render(r.tile)

immutable Size
    proportions::(Float64, Float64)
end

@api draggable => Draggable <: Behavior begin
    arg(container::Tile)
    curry(tile::Tile)
    kwarg(name::Symbol=:_draggable)
end

immutable Drag
    fraction::(Float64, Float64)
end

@api sortable => Sortable <: Behavior begin
    arg(tile::TileList)
    kwarg(name::Symbol=:_sortable)
end

immutable PositionSwap
    swap::(Int, Int)
end

