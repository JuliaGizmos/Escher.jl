import Patchwork.div

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
       pad,
       padcontent

# To abstract away the DOM's bullshit, we will call renderable
# Canvas elements Tile and define well-behaved functions on it

abstract Tile

immutable Leaf <: Tile
    element::Elem
end

convert(::Type{Tile}, x::Elem) = Leaf(x)

abstract Axis

immutable XAxis <: Axis end
immutable YAxis <: Axis end
immutable ZAxis <: Axis end

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

# 1. place an element inside another

immutable Direction{T <: Axis, direction} end

const Right   = Direction{XAxis, +1}
const Left    = Direction{XAxis, -1}
const Up      = Direction{YAxis, +1}
const Down    = Direction{YAxis, -1}
const Outward = Direction{ZAxis, +1}
const Inward  = Direction{ZAxis, -1}

string(d::Right)   = "right"
string(d::Left)    = "left"
string(d::Down)    = "down"
string(d::Up)      = "up"
string(d::Outward) = "outward"
string(d::Inward)  = "inward"

# 2. pad content
immutable Padded{T <: Union(Axis, Direction, Nothing)} <: Tile
    tile::Tile
    len::Length
end

padcontent(tile, len::Length) =
    Padded{nothing}(tile, len)

padcontent{T <: Union(Axis, Direction)}(
    tile, axis::T,
    len::Length) = Padded{T}(tile, len)


immutable Wrap <: Tile
    tile::Tile
end

pad(tile, args...) =
    padcontent(Wrap(tile), args...)

# 3. flow / fill

immutable Flow{Stack <: Direction, Wrap <: Union(Direction, Nothing)}
    tiles::AbstractVector{Tile}
end

flow{T <: Direction}(tiles, direction::T) =
    Flow{T, nothing}(tiles)

flow{Dir <: Direction, Wrap <: Direction}(
    tiles,
    stack::Direction,
    wrap::Wrap) = Fill{Dir, Wrap}(tiles)

abstract AlignContext

immutable Outer{T <: Direction} <: AlignContext end
immutable Content <: AlignContext end

######################################################################

# CSS Setup
function load_layout_css()
    layoutcss = joinpath(Pkg.dir("Canvas"), "assets", "layout.css")
    display(MIME("text/html"), "<style>$(
        readall(open(layoutcss))
    )</style>")
end

try
    load_layout_css()
catch
end
