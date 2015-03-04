module Canvas

using Patchwork
using Reactive
using Requires

import Base: writemime

# Export from Patchwork
export Elem, div, h1, h2, h3, h4, h5, p, blockquote, em, strong

export Tile

# A Tile is a renderable value.
abstract Tile

# Polymer Setup
custom_elements() =
    readall(Pkg.dir("Canvas", "assets", "vulcanized.html"))

include("length.jl")
include("util.jl")
include("layout.jl")
include("looks.jl")
include("signal.jl")
include("behaviour.jl")
include("widget.jl")

include("library/codemirror.jl")

include("render.jl")
include("lazyload.jl")

# Fallback to Patchwork writemime
writemime(io::IO, m::MIME"text/html", x::Tile) =
    writemime(io, m, Canvas.render(x))

writemime{T <: Tile}(io::IO, m::MIME"text/html", x::Signal{T}) =
    writemime(io, m, lift(Canvas.render, Patchwork.Elem, x))

end
