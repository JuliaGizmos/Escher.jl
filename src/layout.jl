
import Patchwork.div
import Base: convert

export place,
       offset,
       TopLeft,
       MidTop,
       TopRight,
       MidLeft,
       Middle,
       MidRight,
       BottomLeft,
       MidBottom,
       BottomRight,
       flow,
       XAxis,
       YAxis,
       Left,
       Right,
       Up,
       Down,
       Inward,
       Outward,
       flow,
       flex,
       pad,
       padcontent

# To abstract away the DOM's bullshit, we will call renderable
# Canvas elements Tile and define well-behaved functions on it

abstract Tile

immutable Leaf <: Tile
    element::Elem
end

convert{ns, tag}(::Type{Tile}, x::Elem{ns, tag}) = Leaf(x)

# 1. Placing a Tile inside another
abstract Position
abstract Corner <: Position

immutable TopLeft     <: Corner end
immutable MidTop      <: Corner end
immutable TopRight    <: Corner end
immutable MidLeft     <: Corner end
immutable Middle      <: Corner end
immutable MidRight    <: Corner end
immutable BottomLeft  <: Corner end
immutable MidBottom   <: Corner end
immutable BottomRight <: Corner end

immutable Relative{T <: Corner} <: Position
    x::Length
    y::Length
    # z::Length
end

immutable Positioned <: Tile
    position::Position
    contained::Tile
    containing::Tile
end

offset{T <: Corner}(corner::T, x, y) =
    Relative{T}(x, y)
offset(x, y) = offset(TopLeft(), x, y)

place(pos::Position, a, b) =
    Positioned(pos, a, b)

# 2. Axes, Directions and Flow

abstract Axis
immutable Horizontal   <: Axis end
immutable Vertical     <: Axis end
immutable Depth        <: Axis end

abstract FlowRelative <: Axis
immutable MainAxis     <: FlowRelative end
immutable CrossAxis    <: FlowRelative end

abstract  Direction{T <: Axis}
immutable Left       <: Direction{Horizontal} end
immutable Right      <: Direction{Horizontal} end
immutable Up         <: Direction{Vertical} end
immutable Down       <: Direction{Vertical} end
immutable Outward    <: Direction{Depth} end
immutable Inward     <: Direction{Depth} end
immutable MainStart  <: Direction{MainAxis} end
immutable MainEnd    <: Direction{MainAxis} end
immutable CrossStart <: Direction{CrossAxis} end
immutable CrossEnd   <: Direction{CrossAxis} end

immutable Flow{Stack <: Union(Axis, Direction),
               Wrap <: Union(Direction, Nothing)} <: Tile
    tiles::AbstractVector{Tile}
end

flow{T <: Direction}(direction::T, tiles) =
    Flow{T, Nothing}(tiles)

flow{Dir <: Direction, Wrap <: Direction}(
    stack::Dir,
    wrap::Wrap,
    tiles) = Fill{Dir, Wrap}(tiles)

# 3. Flexeding and alignment

immutable Flexed <: Tile
    tile::Tile
    factor::Float64
end

flex(factor::Real, t) = Flexed(factor, t)
flex(t) = Flexed(1.0, t)
flex{T <: Real}(factor::AbstractVector{T}, t) =
    map(flex, factor, t)
flex(t::AbstractVector) =
    map(flex, t)

# 4. Pad content

# we show the finger to CSS's margins, they are far from simple
# to reason about and have special meanings in different contexts
# (auto margin, margin collapsing etc), if you want to
# give a fixed space around a tile, you can pad it. `pad` in
# Canvas wraps the tile in another tile and adds padding.
# to pad an element like you would in CSS, use `padcontent`.

immutable Padded{T <: Union(Axis, Direction, Nothing)} <: Tile
    len::Length
    tile::Tile
end

padcontent(len::Length, tile) =
    Padded{Nothing}(len, tile)

padcontent{T <: Union(Axis, Direction)}(
    axis::T,
    len::Length, tile) = Padded{T}(tile, len)

immutable Wrap <: Tile
    tile::Tile
end

pad(tile, args...) =
    padcontent(Wrap(tile), args...)
