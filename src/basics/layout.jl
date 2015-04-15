
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
       floating,
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

@api width => Width <: Tile begin
    typedarg(prefix::String="")
    arg(w::Length)
    curry(tile::Tile)
end

render(t::Width) =
    render(t.tile) & [:style => [(t.prefix == "" ? "width" : t.prefix * "Width")=> t.w]]

@api height => Height <: Tile begin
    typedarg(prefix::String="")
    arg(h::Length)
    curry(tile::Tile)
end

render(t::Height) =
    render(t.tile) & [:style => [(t.prefix == "" ? "height" : t.prefix * "Height")=> t.h]]

minwidth(w, x...) = width("min", w, x...)
minheight(h, x...) = height("min", h, x...)

maxwidth(w, x...) = width("max", w, x...)
maxheight(h, x...) = height("max", h, x...)

size(w::Length, h::Length, t) =
    width(w, height(h, t))
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

render{C <: Corner}(::C) = string(C)

immutable Relative{T <: Corner} <: Position
    x::Length
    y::Length
    # z::Length
end

@api inset => Inset <: Tile begin
    typedarg(position::Position=topleft)
    arg(containing::Tile)
    curry(contained::Tile)
end

render_position(p::TopLeft, x, y) =
    [:top => y, :left => x]
render_position(p::MidTop, x, y) =
    [:left =>  50cent, :top => y,
     :transform => "translate(-50%)",
     :marginLeft => x]
render_position(p::TopRight, x, y) =
    [:top => x, :right => y]
render_position(p::MidLeft, x, y) =
    [:top => 50cent, :left => x,
     :marginTop => y,
     :transform => "translate(0, -50%)"]
render_position(p::Middle, x, y) =
    [:top => 50cent, :left=>50cent,
     :marginLeft => x, :marginTop => y,
     :transform => "translate(-50%, -50%)"]
render_position(p::MidRight, x, y) =
    [:top => 50cent,
    :transform => "translate(0, -50%)",
    :marginTop => y, :right => x]
render_position(p::BottomLeft, x, y) =
    [:bottom => y, :left => x]
render_position(p::MidBottom, x, y) =
    [:left => 50cent, :bottom => y,
     :marginLeft => x,
     :transform => "translate(-50%)"]
render_position(p::BottomRight, x, y) =
    [:bottom => y, :right => x]

render_position(c::Corner) = [:style => render_position(c, 0, 0)]
render_position{C <: Corner}(p::Relative{C}) =
    [:style => render_position(C(), p.x, p.y)]

function render(tile::Inset)
    outer = render(tile.containing)
    inner = render(tile.contained)

    outer &= [:style => [:position => :relative]]
    inner &= [:style => [:position => :absolute]]

    outer << (inner & render_position(tile.position))
end

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

name(s::Left) = "Left"
name(s::Right) = "Right"
name(s::TopSide) = "Top"
name(s::Bottom) = "Bottom"

@terms Side{Depth} begin
    inward => Inward
    outward => Outward
end

# TODO: render inward, outward flow

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

render(f::FlexContainer) =
    addclasses(render(f.tile), classes(f))


@api flow => Flow{A <: FixedAxis} <: FlexContainer begin
    typedarg(axis::A)
    curry(tiles::TileList)
    kwarg(reverse::Bool=false)
end
Flow{T}(x::T, y, z) = Flow{T}(x, y, z) # Julia issue 10641

flow(axis::FixedAxis, tiles...; reverse=false) =
    flow(axis, [t for t in tiles]; reverse=reverse)

Base.reverse(flow::Flow) =
    Flow(flow.axis, flow.tiles, !flow.reverse)


classes(f::Flow{Horizontal}) =
    f.reverse ? "flow flow-reverse horizontal" : "flow horizontal"
classes(f::Flow{Vertical}) =
    f.reverse ? "flow flow-reverse vertical" : "flow vertical"

render(f::Flow) =
    addclasses(render(f.tiles, :div), classes(f))


hbox(args...) = flow(horizontal, args...)
vbox(args...) = flow(vertical, args...)

hbox(arg) = flow(horizontal, [arg])
vbox(arg) = flow(vertical, [arg])

vskip(y) = size(0px, y, empty)
hskip(x) = size(x, 0px, empty)


@api ordering => FlowOrder <: FlexContainer begin
    arg(ordering::AbstractArray)
    curry(flow::FlexContainer)
end

# TODO: render ordering

@api wrap => Wrap <: FlexContainer begin
    arg(tile::FlexContainer)
    kwarg(reverse::Bool=false)
end
wrapreverse(t) = wrap(t, reverse=true)

classes(f::Wrap) =
    f.reverse ? "flex-wrap-reverse" : "flex-wrap"

# 3. Flexing and alignment

@api floating => FloatingTile{T <: Side{Horizontal}} <: Tile begin
    typedarg(side::T)
    curry(tile::Tile)
end

render(f::FloatingTile) =
    render(f.tile) & [:style => [:float => lowercase(name(f.side))]]

@api grow => Grow <: Tile begin
    arg(factor::Float64)
    curry(tile::Tile)
end
grow(t::Tile) = grow(1.0, t)
grow(t::AbstractVector) = map(grow, t)

render(t::Grow) =
    render(t.tile) & [:style => [:flexGrow => t.factor]]

@api shrink => Shrink <: Tile begin
    arg(factor::Float64)
    curry(tile::Tile)
end
shrink(t::Tile) = shrink(1.0, t)
shrink(t::AbstractVector) = map(shrink, t)

render(t::Shrink) =
    render(t.tile) & [:style => [:flexShrink => t.factor]]

@api flexbasis => FlexBasis <: Tile begin
    arg(basis::Union(Length, Symbol))
    curry(tile::Tile)
end

render(t::FlexBasis) =
    render(t.tile) & [:style => [:flexBasis => t.basis]]

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

@api packlines => PackedLines{T <: Packing} <: FlexContainer begin
    typedarg(packing::T)
    curry(tile::FlexContainer)
end

classes(t::PackedLines{AxisStart}) = "pack-lines-start"
classes(t::PackedLines{AxisEnd}) = "pack-lines-end"
classes(t::PackedLines{AxisCenter}) = "pack-lines-center"
classes(t::PackedLines{Stretch}) = "pack-lines-stretch"
classes(t::PackedLines{SpaceBetween}) = "pack-lines-space-between"
classes(t::PackedLines{SpaceAround}) = "pack-lines-space-around"


@api packitems => PackedItems{T <: Packing} <: FlexContainer begin
    typedarg(packing::T)
    curry(tile::FlexContainer)
end

classes(t::PackedItems{AxisStart}) = "pack-start"
classes(t::PackedItems{AxisEnd}) = "pack-end"
classes(t::PackedItems{AxisCenter}) = "pack-center"
classes(t::PackedItems{SpaceBetween}) = "pack-space-between"
classes(t::PackedItems{SpaceAround}) = "pack-space-around"


@api packacross => PackedAcross{T <: Packing} <: FlexContainer begin
    typedarg(packing::T)
    curry(tile::FlexContainer)
end

classes(t::PackedAcross{AxisStart}) = "pack-across-start"
classes(t::PackedAcross{AxisEnd}) = "pack-across-end"
classes(t::PackedAcross{AxisCenter}) = "pack-across-center"
classes(t::PackedAcross{Stretch}) = "pack-across-stretch"
classes(t::PackedAcross{Baseline}) = "pack-across-baseline"


# 4. Padding

immutable Container <: Tile
    tile::Tile
end

render(cont::Container) = Elem(:div, render(cont.tile))


immutable Padded <: Tile
    sides::AbstractVector
    length::Length
    tile::Tile
end

render(padded::Padded) =
    render(padded.tile) &
        (isempty(padded.sides) ? # Apply padding to all sides if none specified
                [:style => ["padding" => padded.length]] :
                [:style => ["padding" * name(p) => padded.length for p=padded.sides]])


padcontent(len::Length, tile) =
    Padded(Side[], len, tile)

padcontent(sides::AbstractVector, len::Length, tile) =
    Padded(sides, len, tile)

pad(len::Length, tile) =
    padcontent(len, Container(tile))

pad(sides::AbstractVector, len::Length, tile) =
    padcontent(len, Container(tile))

pad(len::Length) =
    t -> pad(len, t)

pad(d::AbstractVector, len::Length) =
    t -> pad(d, len, t)

pad(side::Side, len::Length) =
    pad([side], len)
