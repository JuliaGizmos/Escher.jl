module Canvas

if VERSION < v"0.4.0-dev"
    using Docile
end

@docstrings

using Patchwork
using Reactive
using JSON

import Base: convert, writemime

# Polymer Setup
custom_elements() =
    readall(Pkg.dir("Canvas", "assets", "basics/basics.html"))

include("basics/macros.jl")
include("basics/tile.jl")
include("basics/util.jl")
include("basics/length.jl")
include("basics/signal.jl")
include("basics/lazyload.jl")

include("basics/layout.jl")
include("basics/content.jl")
include("basics/typography.jl")
include("basics/embellishment.jl")
include("basics/behaviour.jl")
include("basics/window.jl")

include("library/markdown.jl")
include("library/latex.jl")
include("library/widgets.jl")
include("library/layout2.jl")
include("library/slideshow.jl")
include("library/codemirror.jl")

end

