# Length

using JSON
import Base: convert

export em, cm, mm, inch, pt, pc, px, ex, vw, vh, vmin, cent

@doc """
Type for representing CSS length measures.
""" ->
immutable Length{unit}
    value::Float64
end

@doc " 1mm " ->
const mm = Length{:mm}(1.0)
@doc " 1em " ->
const em = Length{:em}(1.0)
@doc " 1cm " ->
const cm = Length{:cm}(1.0)
@doc " 1inch " ->
const inch = Length{:in}(1.0)
@doc " 1pt " ->
const pt = Length{:pt}(1.0)
@doc " 1px " ->
const px = Length{:px}(1.0)
@doc " 1vw " ->
const vw = Length{:vw}(1.0)
@doc " 1vh " ->
const vh = Length{:vh}(1.0)
@doc " 1vmin " ->
const vmin = Length{:vmin}(1.0)
@doc " 1 percent " ->
const cent = Length{:cent}(1.0)

*{T <: Length}(l::T, n::Real) = T(n * l.value)
*(n::Real, l::Length) = l * n
/{T <: Length}(l::T, n::Real) = T(l.value / n)
+{T <: Length}(l::T, r::T) = T(l.value + r.value)
-{T <: Length}(l::T, r::T) = T(l.value - r.value)

convert(::Type{Length}, x::Real) =
    x * 100.0cent

Base.string{unit}(x::Length{unit}) = string(x.value, unit)
Base.string(x::Length{:cent}) = string(x.value, :%)
JSON._print(io::IO, ::JSON.State, x::Length) = Base.print(io, "\"", string(x), "\"")
