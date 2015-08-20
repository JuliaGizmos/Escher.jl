export Tile, render

import Base: convert, writemime

@doc """
A `Tile` is the basic currency in Escher.
Most of the functions in the Escher API take `Tile`s
among other things as arguments, and return a `Tile` as the result.

Tiles are immutable: once created there is no way to mutate them.
""" ->
abstract Tile

render{T <: Tile}(x::T, state) =
    error("$T cannot be rendered.")

immutable Leaf <: Tile
    element::Elem
end
render(x::Elem, state) = x
render(x::Leaf, state) = x.element

convert(::Type{Tile}, x::String) = Leaf(Elem(:span, x))
convert(::Type{Tile}, x::Char) = Leaf(Elem(:span, string(x)))
convert{ns, tag}(::Type{Tile}, x::Elem{ns, tag}) = Leaf(x)

bestmime(val) = begin
  for mime in ("text/html", "image/svg+xml", "image/png", "text/plain")
    mimewritable(mime, val) && return MIME(symbol(mime))
  end
  error("Cannot render $val.")
end

render_fallback(m::MIME"text/plain", x) = Elem(:div, stringmime(m, x))
render_fallback(m::MIME"text/html", x) = Elem(:div, innerHTML=stringmime(m, x))
render_fallback(m::MIME"image/svg+xml", x) = Elem(:div, innerHTML=stringmime(m, x))
render_fallback(m::MIME"image/png", x) =
    Elem(:img, src="data:image/png;base64," * stringmime(m, x))

render(x::FloatingPoint, state) = render(@sprintf "%0.3f" x, state)
render(x::Symbol, state) = render(string(x), state)
render(x::String, state) = Elem(:span, x)

render{T}(x::T, state) =
    try
        render(convert(Tile, x), state)
    catch err
        # If something other than the conversion failed, rethrow...
        !isa(err, MethodError) && rethrow()
        render_fallback(bestmime(x), x)
    end

@doc """
`Empty` is handy tile that is well... Empty.
use `empty` constant exported by Escher in your code.
""" ->
immutable Empty <: Tile
end

@doc """
An Empty element.
""" ->
const empty = Empty()

render(t::Empty, state) = Elem(:div)

#  writemime(io::IO, m::MIME"text/html", x::Tile) =
#      writemime(io, m, Elem(:div, Escher.render(x, Dict()), className="escherRoot"))
#
#  writemime{T <: Tile}(io::IO, m::MIME"text/html", x::Signal{T}) =
#      writemime(io, m, lift(Escher.render, Patchwork.Elem, x))

# Note a TileList is NOT a Tile
immutable TileList
    tiles::AbstractArray
end

convert(::Type{TileList}, xs::AbstractArray) =
    TileList(xs)
convert(::Type{TileList}, xs::Tuple) =
    TileList([x for x in xs])
convert(::Type{TileList}, x::TileList) = x
convert(::Type{TileList}, x) =
    TileList([x])

render(t::TileList, state) =
    map(x -> render(x, state), t.tiles)

render(t::TileList, wrap, state) =
    Elem(wrap, Elem[render(x, state) for x in t.tiles])
