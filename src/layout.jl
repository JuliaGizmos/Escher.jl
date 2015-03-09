
import Patchwork.div
import Base: size

export inset,
       empty,
       container,
       offset,
       width,
       height,
       minwidth,
       minheight,
       maxwidth,
       maxheight,
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
       top,
       bottom,
       inward,
       outward,
       flow,
       hbox,
       vbox,
       vskip,
       hskip,
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

# 0. Width and height

immutable Width{stage} <: Tile
    w::Length
    tile::Tile
end

immutable Height{stage} <: Tile
    h::Length
    tile::Tile
end

width(w, t) = Width{:natural}(w, t)
height(h, t) = Height{:natural}(h, t)

width(w)  = t -> width(w, t)
height(h) = t -> height(h, t)

minwidth(w, t) = Width{:min}(w, t)
minheight(h, t) = Height{:min}(h, t)

minwidth(w)  = t -> minwidth(w, t)
minheight(h) = t -> minheight(h, t)

maxwidth(w, t) = Width{:max}(w, t)
maxheight(h, t) = Height{:max}(h, t)

maxwidth(w)  = t -> maxwidth(w, t)
maxheight(h) = t -> maxheight(h, t)

size(w::Length, h::Length, t) =
    t |> width(w) |> height(h)
size(w::Length, h::Length) =
    t -> size(w, h, t)

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

immutable Inset <: Tile
    position::Position
    containing::Tile
    contained::Tile
end

offset{T <: Corner}(corner::T, x, y) =
    Relative{T}(x, y)
offset(x, y) = offset(TopLeft(), x, y)

inset(pos::Position, outer, inner) =
    Inset(pos, outer, inner)

inset(outer, inner) =
    Inset(topleft, outer, inner)

inset(x::Length, y::Length, a, b) =
    Inset(offset(x, y), a, b)

inset(p::Position) = (x...) -> inset(p, x...)
inset(p::Position, outer) = inner -> inset(p, outer, inner)

# 2. Axes, Directions and Flow

abstract Axis

abstract FixedAxis <: Axis
@terms FixedAxis begin
    horizontal => Horizontal
    vertical => Vertical
    depth => Depth
end

abstract  Side{Perpendicular <: Axis}

@terms Side{Horizontal} begin
    left => Left
    right => Right
end

@terms Side{Vertical} begin
    top => TopSide
    bottom => Bottom
end

@terms Side{Depth} begin
    inward => Inward
    outward => Outward
end

abstract FlowRelativeAxis <: Axis
@terms FlowRelativeAxis begin
    mainaxis => MainAxis
    crossaxis => CrossAxis
end

@terms Side{MainAxis} begin
    mainstart => MainStart
    mainend => MainEnd
end

@terms Side{CrossAxis} begin
    crossstart => CrossStart
    crossend => CrossEnd
end

abstract FlexContainer <: Tile
immutable Flow{Along <: FixedAxis, reverse} <: FlexContainer
    tiles::AbstractVector
end

flow{T <: FixedAxis}(axis::T, tiles::AbstractArray; reverse=false) =
    Flow{T, reverse}([convert(Tile, t) for t in tiles])

flow(axis::FixedAxis, tiles::Tuple; reverse=false) =
    flow(axis, [t for t in tiles]; reverse=reverse)

flow(axis::FixedAxis, tiles...; reverse=false) =
    flow(axis, tiles; reverse=reverse)

Base.reverse{T, x}(flow::Flow{T, x}) =
    Flow{T, (!x)}(flow.tiles)

hbox(args...) = flow(horizontal, args...)
vbox(args...) = flow(vertical, args...)

vskip(y) = size(0px, y, empty)
hskip(x) = size(x, 0px, empty)

immutable Wrap{reverse} <: FlexContainer
    tile::FlexContainer
end
wrap(t) = Wrap{false}(t)
wrapreverse(t) = Wrap(t)

# 3. Flexing and alignment

immutable FloatingTile{T <: Side{Horizontal}} <: Tile
    tile::Tile
end

float{T <: Side{Horizontal}}(d::T, tile) =
    FloatingTile{T}(tile)
float(d::Side{Horizontal}) =
    t -> float(d, t)

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
flex() = flex(empty)
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

# 4. Padding

immutable Container <: Tile
    tile::Tile
end

immutable Padded <: Tile
    sides::AbstractVector{Side}
    length::Length
    tile::Tile
end

padcontent(len::Length, tile) =
    Padded(Side[], len, tile)

padcontent(sides::AbstractVector{Side}, len::Length, tile) =
    Padded(sides, len, tile)

pad(len::Length, tile) =
    padcontent(len, Container(tile))

pad(sides::AbstractVector{Side}, len::Length, tile) =
    padcontent(len, Container(tile))

pad(len::Length) =
    t -> pad(len, t)

pad(d::AbstractVector{Side}, len::Length) =
    t -> pad(d, len, t)
