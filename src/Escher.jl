module Escher

if VERSION < v"0.4.0-dev"
    using Docile
end

if VERSION < v"0.4.0-dev"
    using Markdown
else
    using Base.Markdown
end

export @md_str, @md_mstr
#@docstrings

using Compat
using Patchwork
using Reactive
using JSON

# Polymer Setup
custom_elements() =
    readall(Pkg.dir("Escher", "assets", "basics/basics.html"))

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
include("basics/behavior.jl")
include("basics/window.jl")

include("library/markdown.jl")
include("library/tex.jl")
include("library/widgets.jl")
include("library/layout2.jl")
include("library/slideshow.jl")
include("library/codemirror.jl")

include("deprecate.jl")

end
