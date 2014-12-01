import Patchwork.div
import Base: convert

export Offset,
       place,
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

immutable Corner{X, Y} <: Position end
          # Until holograms become mainstream...

const TopLeft     = Corner{-1, -1}
const MidLeft     = Corner{-1,  0}
const BottomLeft  = Corner{-1, +1}

const MidTop      = Corner{0,  -1}
const Middle      = Corner{0,   0}
const MidBottom   = Corner{0,  +1}

const TopRight    = Corner{+1, -1}
const MidRight    = Corner{+1,  0}
const BottomRight = Corner{+1, +1}

immutable Relative{T <: Corner}
    x::Length
    y::Length
    # z::Length
end

immutable Positioned <: Tile
    contained_elem::Tile
    containing_elem::Tile
    position::Relative
end

place(a, b, pos::Relative) =
    Place(a, b, pos)

# 2. Axes, Directions and Flow

abstract Axis

abstract CartesianAxis <: Axis

immutable XAxis <: CartesianAxis end
immutable YAxis <: CartesianAxis end
immutable ZAxis <: CartesianAxis end

abstract FlowRelativeAxis <: Axis

immutable MainAxis  <: FlowRelativeAxis end
immutable CrossAxis <: FlowRelativeAxis end

abstract DirectionAlong{T <: Axis}

immutable Direction{T <: Axis, direction} <: DirectionAlong{T} end

const Right   = Direction{XAxis, +1}
const Left    = Direction{XAxis, -1}
const Up      = Direction{YAxis, +1}
const Down    = Direction{YAxis, -1}
const Outward = Direction{ZAxis, +1}
const Inward  = Direction{ZAxis, -1}

const MainStart  = Direction{MainAxis,  -1}
const MainEnd    = Direction{MainAxis,  +1}
const CrossStart = Direction{CrossAxis, -1}
const CrossEnd   = Direction{CrossAxis, +1}

reverse{T <: Axis}(::Direction{T, -1}) = Direction{T, +1}()
reverse{T <: Axis}(::Direction{T, +1}) = Direction{T, -1}()

immutable Flow{Stack <: Union(Axis, Direction),
               Wrap <: Union(Direction, Nothing)} <: Tile
    tiles::AbstractVector{Tile}
end

flow{T <: Direction}(tiles, direction::T) =
    Flow{T, Nothing}(tiles)

flow{Dir <: Direction, Wrap <: Direction}(
    tiles,
    stack::Dir,
    wrap::Wrap) = Fill{Dir, Wrap}(tiles)

# 3. Flexeding and alignment

immutable Flexed <: Tile
    tile::Tile
    factor::Float64
end

flex(t, factor::Real) = Flexed(t, factor)
flex(t) = Flexed(t, 1.0)
flex{T <: Real}(t, factor::AbstractVector{T}) =
    map(flex, t, factor)

@vectorize_1arg Any flex

abstract AlignContext
immutable Items <: AlignContext end
immutable Content <: AlignContext end
immutable Self <: AlignContext end

immutable Aligned{Ctx <: AlignContext,
                  To <: Union(Direction, Axis)} <: Tile
    tile::Tile
end

align(flow::Flow, d::Union(Direction, Axis)) =
    align(flow, Items(), d)

align(flow::Flow, ::Items, d::Union(Direction, Axis)) =
    Aligned{Items}(flow, d)

align(anything, ::Items, d::Union(Direction, Axis)) =
    error("You can only align items inside a Flow")

align(tile, d::Union(Direction, Axis)) =
    Aligned{Self}(tile, d)

align{T <: AlignContext}(tile, ctx::T, d::Union(Direction, Axis)) =
    Aligned{T}(tile, d)

# 4. Pad content

# we show the finger to CSS's margins, they are far from simple
# to reason about and have special meanings in different contexts
# (auto margin, margin collapsing etc), if you want to
# give a fixed space around a tile, you can pad it. `pad` in
# Canvas wraps the tile in another tile and adds padding.
# to pad an element like you would in CSS, use `padcontent`.

immutable Padded{T <: Union(Axis, Direction, Nothing)} <: Tile
    tile::Tile
    len::Length
end

padcontent(tile, len::Length) =
    Padded{Nothing}(tile, len)

padcontent{T <: Union(Axis, Direction)}(
    tile, axis::T,
    len::Length) = Padded{T}(tile, len)

immutable Wrap <: Tile
    tile::Tile
end

pad(tile, args...) =
    padcontent(Wrap(tile), args...)
