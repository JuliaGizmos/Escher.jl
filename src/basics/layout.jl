
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
       padcontent,
       hidden,
       visible,
       scroll,
       auto,
       clip

# 0. Width and height

@api width => (Width <: Tile) begin
    doc("Set the width of a tile")
    typedarg(prefix::String="",
        doc=md"""either `""`, `"min"` or `"max"`. See `minwidth` and `maxwidth`.""")
    arg(width::Length, doc="The width")
    curry(tile::Tile, doc="the tile to set the height of")
end
render(t::Width, state) = begin
    prefixed = t.prefix == "" ? "width" : t.prefix * "Width"
    render(t.tile, state) & style(@d(prefixed => t.width))
end

@api height => (Height <: Tile) begin
    doc("Set the height of a tile")
    typedarg(prefix::String="",
        doc=md"""either `""`, `"min"` or `"max"`. See `minheight` and `maxheight`.""")
    arg(height::Length, doc="the height")
    curry(tile::Tile, doc="the tile to set the height of")
end

render(t::Height, state) =
    render(t.tile, state) &
        style(@d((t.prefix == "" ? "height" : t.prefix * "Height") => t.height))

minwidth(w, x...) = width("min", w, x...)
minheight(h, x...) = height("min", h, x...)

@apidoc minwidth => (Width <: Tile) begin
    doc("Set the minimum width of a tile")
    arg(height::Length, doc="the width")
    curry(tile::Tile, doc="the tile to set the width of")
end

@apidoc minheight => (Height <: Tile) begin
    doc("Set the minimum height of a tile")
    arg(height::Length, doc="the height")
    curry(tile::Tile, doc="the tile to set the height of")
end

maxwidth(w, x...) = width("max", w, x...)
maxheight(h, x...) = height("max", h, x...)

@apidoc maxwidth => (Width <: Tile) begin
    doc("Set the maximum width of a tile")
    arg(height::Length, doc="the width")
    curry(tile::Tile, doc="the tile to set the width of")
end

@apidoc maxheight => (Height <: Tile) begin
    doc("Set the maximum height of a tile")
    arg(height::Length, doc="the height")
    curry(tile::Tile, doc="the tile to set the height of")
end

size(w::Length, h::Length, t) =
    width(w, height(h, t))
size(w::Length, h::Length) =
    t -> size(w, h, t)

@apidoc size => (Height <: Tile) begin
    doc("Set the width and the height of a tile")
    arg(width::Length, doc="the width")
    arg(height::Length, doc="the height")
    curry(tile::Tile, doc="the tile to set the size of")
end
container(w, h) =
    empty |> size(w, h)

@apidoc container => (Height <: Tile) begin
    doc("Make an empty tile of a given size")
    arg(width::Length, doc="the width")
    arg(height::Length, doc="the height")
end

# 1. Placing a Tile inside another
abstract Position
abstract Corner <: Position

@terms Corner begin
    topleft     => TopLeft
    midtop      => MidTop
    topright    => TopRight
    midleft     => MidLeft
    middle      => Middle
    midright    => MidRight
    bottomleft  => BottomLeft
    midbottom   => MidBottom
    bottomright => BottomRight
end

name{C <: Corner}(::C) = string(C)

@api offset => (Relative{T <: Corner} <: Position) begin
    doc("Create an offset relative to a corner")
    arg(c::T, doc="The corner to offset from")
    arg(x::Length, doc="The horizontal offset")
    arg(y::Length, doc="The vertical offset")
    # z::Length
end

@api inset => (Inset <: Tile) begin
    doc("Position a tile inside a container tile at a corner or an offset")
    typedarg(position::Position=topleft, doc="The corner or the offset")
    arg(container::Tile, doc="The container")
    curry(contained::Tile, doc="The tile to be placed inside")
end

render_position(p::TopLeft, x, y) =
    @d(:top => y, :left => x)
render_position(p::MidTop, x, y) =
    @d(:left =>  50cent, :top => y,
     :transform => "translate(-50%)",
     :marginLeft => x)
render_position(p::TopRight, x, y) =
    @d(:top => x, :right => y)
render_position(p::MidLeft, x, y) =
    @d(:top => 50cent, :left => x,
     :marginTop => y,
     :transform => "translate(0, -50%)")
render_position(p::Middle, x, y) =
    @d(:top => 50cent, :left=>50cent,
     :marginLeft => x, :marginTop => y,
     :transform => "translate(-50%, -50%)")
render_position(p::MidRight, x, y) =
    @d(:top => 50cent,
    :transform => "translate(0, -50%)",
    :marginTop => y, :right => x)
render_position(p::BottomLeft, x, y) =
    @d(:bottom => y, :left => x)
render_position(p::MidBottom, x, y) =
    @d(:left => 50cent, :bottom => y,
     :marginLeft => x,
     :transform => "translate(-50%)")
render_position(p::BottomRight, x, y) =
    @d(:bottom => y, :right => x)

render_position(c::Corner) = style(render_position(c, 0, 0))
render_position{C <: Corner}(p::Relative{C}) =
    style(render_position(C(), p.x, p.y))

render(tile::Inset, state) = begin
    outer = render(tile.container, state)
    inner = render(tile.contained, state)

    outer &= style(@d(:position => :relative))
    inner &= style(@d(:position => :absolute))

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

render(f::FlexContainer, state) =
    addclasses(render(f.tile, state), classes(f))


@api flow => (Flow{A <: FixedAxis} <: FlexContainer) begin
    doc("Flow a list of tiles along the horizontal or the vertical axis")
    typedarg(axis::A, doc="The axis to layout along")
    curry(tiles::TileList, doc="The list of tiles to layout")
    kwarg(reverse::Bool=false, doc="Should the layout be in the reverse order?")
end
Flow{T}(x::T, y, z) = Flow{T}(x, y, z) # Julia issue 10641

flow(axis::FixedAxis, tiles...; reverse=false) =
    flow(axis, [t for t in tiles]; reverse=reverse)

Base.reverse(f::Flow) =
    flow(f.axis, f.tiles, !f.reverse)


classes(f::Flow{Horizontal}) =
    f.reverse ? "flow flow-reverse horizontal" : "flow horizontal"
classes(f::Flow{Vertical}) =
    f.reverse ? "flow flow-reverse vertical" : "flow vertical"

render(f::Flow, state) =
    addclasses(render(f.tiles, :div, state), classes(f))


hbox(args...) = flow(horizontal, args...)

@apidoc hbox => (Flow <: Tile) begin
    doc(md"Arrange tiles horizontally. `hbox(args...)`
is equivalent to `flow(horizontal, args...)`")
    arg(tiles::TileList)
end


vbox(args...) = flow(vertical, args...)

@apidoc vbox => (Flow <: Tile) begin
    doc(md"Arrange tiles vertically. `hbox(args...)`
is equivalent to `flow(vertical, args...)`")
    arg(tiles::TileList)
end

hbox(arg) = flow(horizontal, [arg])
vbox(arg) = flow(vertical, [arg])

vskip(y) = size(0px, y, empty)
hskip(x) = size(x, 0px, empty)


@api ordering => (FlowOrder <: FlexContainer) begin
    arg(ordering::AbstractArray)
    curry(flow::FlexContainer)
end

# TODO: render ordering

@api wrap => (Wrap <: FlexContainer) begin
    doc(md"Wrap a `flow` of tiles")
    arg(tile::FlexContainer, doc=md"Either a `vbox` or a `hbox`")
    kwarg(reverse::Bool=false, doc="Should the wrapping be reversed in direction?")
end
wrapreverse(t) = wrap(t, reverse=true)

classes(f::Wrap) =
    f.reverse ? "flex-wrap-reverse" : "flex-wrap"

# 3. Flexing and alignment

@api floating => (FloatingTile{T <: Side{Horizontal}} <: Tile) begin
    typedarg(side::T)
    curry(tile::Tile)
end

render(f::FloatingTile, state) =
    render(f.tile, state) & style(@d(:float => lowercase(name(f.side))))

@api grow => (Grow <: Tile) begin
    doc(md"""Expand a tile along the main axis to fit extra space in the parent
    `hbox` or `vbox`.""")

    arg(
        factor::Float64,
        doc="""The relative rate at which this tile will expand compared to other
        tiles that can grow.""",
    )

    curry(
        tile::Tile,
        doc=md"The tile to stretch. This tile should go inside a `vbox` or `hbox`",
    )
end
grow(t::Tile) = grow(1.0, t)
grow(t::AbstractVector) = map(grow, t)

render(t::Grow, state) =
    render(t.tile, state) & style(@d(:flexGrow => t.factor))

@api shrink => (Shrink <: Tile) begin
    doc(md"Shrink a tile along the main axis to accomodate space in the parent `hbox` or `vbox`.")
    arg(factor::Float64,
        doc="The relative rate at which this tile will shrink compared to other tiles that can shrink.")
    curry(tile::Tile,
        doc=md"The tile to stretch. This tile should go inside a `vbox` or `hbox`")
end
shrink(t::Tile) = shrink(1.0, t)
shrink(t::AbstractVector) = map(shrink, t)

render(t::Shrink, state) =
    render(t.tile, state) & style(@d(:flexShrink => t.factor))

@api flexbasis => (FlexBasis <: Tile) begin
    arg(basis::Union(Length, Symbol))
    curry(tile::Tile)
end

render(t::FlexBasis, state) =
    render(t.tile, state) & style(@d(:flexBasis => t.basis))

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

@apidoc flex => (FlexBasis <: Tile) begin
    doc("Ignore the width (in a hbox) or height (in a vbox) and stretch or shrink a tile to fill / distribute remaining space")
    arg(tile::Tile, doc="The tile to flex")
end

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

@api packlines => (PackedLines{T <: Packing} <: FlexContainer) begin
    doc("Pack wrapped lines of tiles across the cross axis")
    typedarg(packing::T, doc="The kind of packing to use")
    curry(tile::FlexContainer, doc="The flex container")
end

classes(t::PackedLines{AxisStart}) = "pack-lines-start"
classes(t::PackedLines{AxisEnd}) = "pack-lines-end"
classes(t::PackedLines{AxisCenter}) = "pack-lines-center"
classes(t::PackedLines{Stretch}) = "pack-lines-stretch"
classes(t::PackedLines{SpaceBetween}) = "pack-lines-space-between"
classes(t::PackedLines{SpaceAround}) = "pack-lines-space-around"


@api packitems => (PackedItems{T <: Packing} <: FlexContainer) begin
    doc("Pack items in a flex container along the main axis")
    typedarg(packing::T, doc="The kind of packing to use")
    curry(tile::FlexContainer, doc="The flex container")
end

classes(t::PackedItems{AxisStart}) = "pack-start"
classes(t::PackedItems{AxisEnd}) = "pack-end"
classes(t::PackedItems{AxisCenter}) = "pack-center"
classes(t::PackedItems{SpaceBetween}) = "pack-space-between"
classes(t::PackedItems{SpaceAround}) = "pack-space-around"


@api packacross => (PackedAcross{T <: Packing} <: FlexContainer) begin
    doc("Stretch or provide spacing around items in the cross axis")
    typedarg(packing::T, doc="The kind of packing to use")
    curry(tile::FlexContainer, doc="The flex container")
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

render(cont::Container, state) = Elem(:div, render(cont.tile, state))


@api padcontent => (PadContent <: Tile) begin
    typedarg(sides::AbstractVector=allsides)
    arg(length::Length)
    curry(tile::Tile)
end

render(t::PadContent, state) =
    render(t.tile, state) &
        style(mapparts(allsides, t.sides, "padding", "", t.length))

pad(len::Length, tile) =
    padcontent(len, Container(tile))

pad(len::Length) =
    t -> pad(len, t)

pad(sides::AbstractVector, len::Length, tile) =
    padcontent(sides, len, Container(tile))

pad(sides::AbstractVector, len::Length) =
    tile -> padcontent(sides, len, Container(tile))

@apidoc pad => (PadContent <: Tile) begin
    doc("Wrap a tile in a container with the specified padding")
    typedarg(sides::AbstractVector=allsides, doc="Sides to pad")
    arg(length::Length, doc="Amount of padding")
    curry(tile::Tile, doc="The tile to pad")
end


# Clipping

abstract Overflow

@terms Overflow begin
    hidden => Hidden
    visible => Visible
    scroll => Scroll
    auto => AutoClip
end

@api clip => (Clip <: Tile) begin
    doc(md"Clip a tile to the dimensions set using `width` and `height`.")
    typedarg(
        overflow::Overflow=auto,
        doc=md"""The method for clipping. Valid values are `hidden`, `visible`,
                 `scroll` and `auto`."""
        )
    curry(tile::Tile, doc="The tile to clip.")
end

name(::Hidden) = "hidden"
name(::Visible) = "visible"
name(::Scroll) = "scroll"
name(::AutoClip) = "auto"

render(t::Clip, state) =
    render(Container(t.tile), state) &
        [:style => [:overflow => name(t.overflow)], :className => "scrollbar"]

