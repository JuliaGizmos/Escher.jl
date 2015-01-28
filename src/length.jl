# Length

using JSON
import Base: convert

export em, cm, mm, inch, pt, pc, px, ex, vw, vh, vmin, cent

immutable Length{unit}
    value::Float64
end

const mm = Length{:mm}(1.0)
const em = Length{:em}(1.0)
const cm = Length{:cm}(1.0)
const inch = Length{:in}(1.0)
const pt = Length{:pt}(1.0)
const px = Length{:px}(1.0)
const vw = Length{:vw}(1.0)
const vh = Length{:vh}(1.0)
const vmin = Length{:vmin}(1.0)
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
