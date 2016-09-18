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
    readstring(Pkg.dir("Escher", "assets", "basics/basics.html"))

include("basics/macros.jl")
include("basics/tile.jl")
include("basics/util.jl")
include("basics/length.jl")
include("basics/signal.jl")

include("basics/layout.jl")
include("basics/content.jl")
include("basics/typography.jl")
include("basics/embellishment.jl")
include("basics/behavior.jl")
include("basics/window.jl")
include("basics/component.jl")

include("library/markdown.jl")
include("library/tex.jl")
include("library/widgets.jl")
include("library/layout2.jl")
include("library/slideshow.jl")
include("library/codemirror.jl")

include("deprecate.jl")

# We need to set up convert methods for other packages (e.g. Gadfly, SymPy, Images)
# This will work on 0.3 automatically, when using 0.4 with precompilation,
# an explicit call to conditional_setup is needed after loading the other packages.

if VERSION >= v"0.4.0-"
    external_setup() = include(joinpath(dirname(@__FILE__), "basics", "lazyload.jl"))
else
    external_setup() = nothing
end

serve(port=5555) =
    include(joinpath(dirname(@__FILE__), "cli", "serve.jl"))(port)


# 3rd party package interop
include("basics/lazyload.jl")

end
