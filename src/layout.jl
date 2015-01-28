
import Patchwork.div
import Base: convert, size

export place,
       empty,
       container,
       fullbleed,
       offset,
       width,
       height,
       size,
       topleft,
       midtop,
       topright,
       midleft,
       middle,
       midright,
       bottomleft,
       midbottom,
       bottomright,
       vertical,
       horizontal,
       depth,
       left,
       right,
       up,
       down,
       inward,
       outward,
       flow,
       grow,
       shrink,
       flex,
       wrap,
       axisstart,
       axisend,
       center,
       spacebetween,
       spacearound,
       stretch,
       packitems,
       packacross,
       packlines,
       space,
       pad,
       padcontent

# To abstract away the DOM's bullshit, we will call renderable
# Canvas elements Tile and define well-behaved functions on it

abstract Tile

immutable Leaf <: Tile
    element::Elem
end

immutable Empty <: Tile
end
const empty = Empty()

convert{ns, tag}(::Type{Tile}, x::Elem{ns, tag}) = Leaf(x)
convert(::Type{Tile}, x::String) = Leaf(Elem(:span, x))

# 0. Width and height

immutable Width <: Tile
    w::Length
    tile::Tile
end

immutable Height <: Tile
    h::Length
    tile::Tile
end

width(w, t) = Width(w, t)
height(h, t) = Height(h, t)

width(w)  = t -> width(w, t)
height(h) = t -> height(h, t)

size(w::Length, h::Length, t::Tile) =
    t |> width(w) |> height(h)
size(w::Length, h::Length) =
    t -> size(w, h, t)

fullbleed(x=empty) =
    size(100vw, 100vh, x)

container(w, h) =
    empty |> size(w, h)

# 1. Placing a Tile inside another
abstract Position
abstract Corner <: Position

@terms Corner begin
    topleft => TopLeft
    midtop => MidTop
    topright => TopRight
    midleft => MidLeft
    middle => Middle
    midright => MidRight
    bottomleft => BottomLeft
    midbottom => MidBottom
    bottomright => BottomRight
end

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

place(x::Length, y::Length, a, b) =
    Positioned(offset(x, y), a, b)

# 2. Axes, Directions and Flow

abstract Axis
@terms Axis begin
    horizontal => Horizontal
    vertical => Vertical
    depth => Depth
end

abstract FlowRelative <: Axis

@terms FlowRelative begin
    mainaxis => MainAxis
    crossaxis => CrossAxis
end

abstract  Direction{T <: Axis}

@terms Direction{Horizontal} begin
    left => Left
    right => Right
end

@terms Direction{Vertical} begin
    up => Up
    down => Down
end

@terms Direction{Depth} begin
    inward => Inward
    outward => Outward
end

@terms Direction{MainAxis} begin
    mainstart => MainStart
    mainend => MainEnd
end

@terms Direction{CrossAxis} begin
    crossstart => CrossStart
    crossend => CrossEnd
end

abstract FlexContainer <: Tile

immutable Flow{D <: Direction} <: FlexContainer
    tiles::AbstractVector{Tile}
end

flow{T <: Direction}(direction::T, tiles) =
    Flow{T}(tiles)

flow{T <: Direction}(direction::T) =
    tiles -> Flow{T}(tiles)

immutable Wrap{D <: Direction, T <: Direction} <: Tile
    tile::Flow{T}
end
wrap{T <: Direction, U <: Direction}(d::T, f::Flow{U}) =
    Wrap{T, U}(f)

wrap{T <: Direction}(d::T) =
    tiles -> wrap(d, tiles)

flow{T <: Direction, U <: Direction}(stack::T, wrap_::U, tiles) =
    wrap(wrap_, flow(stack, tiles))

flow(stack::Direction, wrap::Direction) =
   tiles -> flow(stack, wrap, tiles)

# 3. Flexing and alignment

immutable Grow <: Tile
    factor::Float64
    tile::Tile
end

grow(factor::Real, t) = Grow(factor, t)

# TODO: make a macro for this
grow{T <: Real}(factor::AbstractVector{T}, t) =
    map(grow, factor, t)
grow(t) = grow(1.0, t)
grow(t::AbstractVector) =
    map(grow, t)

grow(factor::Real) = t -> grow(factor, t)

immutable Shrink <: Tile
    factor::Float64
    tile::Tile
end
shrink(factor::Real, t) = Shrink(factor, t)
shrink(factor::Real) = t -> shrink(factor, t)

# TODO: make a macro for this
shrink{T <: Real}(factor::AbstractVector{T}, t) =
    map(shrink, factor, t)
shrink(t) = shrink(1.0, t)
shrink(t::AbstractVector) =
    map(shrink, t)

immutable FlexBasis <: Tile
    basis::Union(Length, Symbol)
    tile::Tile
end
flexbasis(basis, tile) = FlexBasis(basis, tile)

# Flex ignores the width and distributes forcefully
flex(factor::Real, t) =
    flexbasis(0mm, grow(factor, t))
flex(t) = flex(1.0, t)
flex{T <: Real}(factor::AbstractVector{T}, t) =
    map(flex, factor, t)
flex(t::AbstractVector) =
    map(flex, t)

flex(factor::Real) = t -> flex(factor, t)
flex{T <: Real}(factor::AbstractVector{T}) = t -> flex(factor, t)

# Flow alignment
abstract Packing

@terms Packing begin
    axisstart => AxisStart
    axisend => AxisEnd
    center => AxisCenter
    stretch => Stretch
    baseline => Baseline
    spacebetween => SpaceBetween
    spacearound => SpaceAround
end

immutable PackedLines{T <: Packing} <: FlexContainer
    tile::FlexContainer
end

packlines{T <: Packing}(packing::T, tile::Wrap) =
    PackedLines{T}(w)

packlines(p::Packing) =
    t -> packlines(p, t)

immutable PackedItems{T <: Packing} <: FlexContainer
    tile::FlexContainer
end

packitems{T <: Packing}(packing::T, tile::FlexContainer) =
    PackedItems{T}(tile)

packitems(p::Packing) =
    t -> packitems(p, t)

immutable PackedAcross{T <: Packing} <: FlexContainer
    tile::FlexContainer
end

packacross{T <: Packing}(pack::T, tile::FlexContainer) =
    PackedAcross{T}(tile)

packacross(p::Packing) =
    t -> packacross(p, t)

immutable FlexSpace{T <: Direction} <: Tile
    tile::Tile
end

space{T <: Direction}(dir::T, tile) =
    FlexSpace{T}(tile)

space(dir::Direction) =
    x -> space(dir, x)

space(dir::Direction, tiles::AbstractArray) =
    map(space(dir), tiles)

# 4. Pad content

# we show the finger to CSS's margins, they are far from simple
# to reason about and have special meanings in different contexts
# (auto margin, margin collapsing etc), if you want to
# give a fixed space around a tile, you can pad it. `pad` in
# Canvas wraps the tile in another tile and adds padding.
# to pad an element like you would in CSS, use `padcontent`.

immutable Container <: Tile
    tile::Tile
end

immutable Padded{T <: Union(Axis, Direction, Nothing)} <: Tile
    len::Length
    tile::Tile
end

padcontent(len::Length, tile) =
    Padded{Nothing}(len, tile)

padcontent{T <: Union(Axis, Direction)}(
    axis::T,
    len::Length, tile) = Padded{T}(len, tile)

pad(len::Length, tile) =
    padcontent(len, Container(tile))

pad(len::Length) =
    t -> pad(len, t)
