export Tile

@doc """
A `Tile` is the basic currency in Canvas.
Most of the functions in the Canvas API take `Tile`s
among other things as arguments, and return a `Tile` as the result.

Tiles are immutable: once created there is no way to mutate them.
""" ->
abstract Tile

immutable Leaf <: Tile
    element::Elem
end

@doc """
`Empty` is handy tile that is well... Empty.
use `empty` constant exported by Canvas in your code.
""" ->
immutable Empty <: Tile
end

@doc """
An Empty element.
""" ->
const empty = Empty()

abstract Tileset <: Tile

immutable TileList <: Tileset
    tiles::AbstractArray
end

tilelist(xs) = TileList(xs)

convert{ns, tag}(::Type{Tile}, x::Elem{ns, tag}) =
    Leaf(x)
convert(::Type{Tile}, x::String) =
    Leaf(Elem(:span, x))
convert(::Type{TileList}, x::Union(Tuple, AbstractArray)) =
    TileList([convert(Tile, t) for t in x])

writemime(io::IO, m::MIME"text/html", x::Tile) =
    writemime(io, m, div(Canvas.render(x), className="canvasRoot"))

writemime{T <: Tile}(io::IO, m::MIME"text/html", x::Signal{T}) =
    writemime(io, m, lift(Canvas.render, Patchwork.Elem, x))
