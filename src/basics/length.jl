# Length

using JSON
using Measures

export mm, cm, inch, pt, em, px, vw, vh, vmin, cent

" 1em "
const em = Length(:em,1.0)
" 1em "
const px = Length(:px,1.0)
" 1vw "
const vw = Length(:vw, 1.0)
" 1vh "
const vh = Length(:vh, 1.0)
" 1vmin "
const vmin = Length(:vmin, 1.0)
" 1 percent "
const cent = Length(:cent, 1.0)

Base.convert(::Type{Length}, x::Real) =
    x * 100.0cent

JSON.lower(x::Length) = string(x)
