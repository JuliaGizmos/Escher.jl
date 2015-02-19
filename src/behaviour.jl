abstract Behaviour <: Tile

export hasstate

immutable WithState{attr} <: Behaviour
    tile::Tile
    trigger::String
end

hasstate(tile::Tile, name; attr="value", trigger="change") =
    WithState{symbol(attr)}(tile, name, attr, trigger)

hasstate(w::Tile, x::Input; tag=:val, attr="value", trigger="change", absorb=true) =
    pipe(hasstate(w, tag, attr=attr, trigger=trigger), tag, x) |>
       (x -> absorb ? stoppropagation(x, tag) : x)

abstract MouseButton

@terms MouseButton begin
    leftbutton => LeftButton
    rightbutton => RightButton
    scrollbutton => ScrollButton
end

immutable Clickable <: Behaviour
    tile::Tile
end

immutable Click
    button::MouseButton
end

clickable(t::Tile) = Clickable(t)

abstract MouseState
@terms MouseState begin
    mousedown => MouseDown
    mouseup => MouseUp
end

immutable Hoverable <: Behaviour
    tile::Tile
    get_coords::Bool
end

immutable Hover
    state::MouseState
    position::(Float64, Float64)
end

hoverable(t::Tile, get_coords=false) = Hoverable(t, get_coords)

immutable Resizable <: Behaviour
    tile::Tile
    container::Tile
end

immutable Size
    proportions::(Float64, Float64)
end

resizable(tile, container) = Resizable(tile, container)

immutable Draggable <: Tile
    tile::Tile
    container::Tile
end

draggable(tile, container) = Draggable(tile, container)

immutable Drag
    fraction::(Float64, Float64)
end

immutable Sortable <: Behaviour
    tile::AbstractArray
end

immutable PositionSwap
    swap::(Int, Int)
end

immutable Editable <: Behaviour
    tile::Tile
end

