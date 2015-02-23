module Canvas

using Patchwork
using Reactive
using Requires

import Base: writemime

# Export from Patchwork
export Elem, div, h1, h2, h3, h4, h5, p, blockquote, em, strong

# Polymer Setup
custom_elements() =
    readall(Pkg.dir("Canvas", "assets", "vulcanized.html"))

include("length.jl")
include("util.jl")
include("layout.jl")
include("looks.jl")
include("behaviour.jl")
include("signal.jl")
include("widget.jl")
include("library/codeeditor.jl")
include("render.jl")

# Fallback to Patchwork writemime
writemime(io::IO, m::MIME"text/html", x::Tile) =
    writemime(io, m, Canvas.render(x))

writemime{T <: Tile}(io::IO, m::MIME"text/html", x::Signal{T}) =
    writemime(io, m, lift(Canvas.render, Patchwork.Elem, x))

@require IJulia begin
    include("ijulia.jl")
end

@require Blink begin
    # This is still defunct though
    import BlinkDisplay, Graphics

    Blink.windowinit() do w
        Blink.head(w, custom_elements())
    end

    Graphics.media(Tile, Graphics.Media.Graphical)
end

@require Gadfly begin
    function convert(::Type{Tile}, p::Gadfly.Plot)
        backend = Compose.Patchable(
                     Compose.default_graphic_width,
                     Compose.default_graphic_height)
        convert(Tile, Compose.draw(backend, p))
    end
end

end
