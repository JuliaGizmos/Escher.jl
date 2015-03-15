module Canvas

if VERSION < v"0.4.0-dev"
    using Docile
end

using Patchwork
using Reactive
using JSON

import Base: convert, writemime

# Polymer Setup
custom_elements() =
    readall(Pkg.dir("Canvas", "assets", "basics/basics.html"))

include("tile.jl")
include("util.jl")
include("length.jl")
include("signal.jl")
include("lazyload.jl")

include("layout.jl")
include("typography.jl")
include("embellishment.jl")
include("behaviour.jl")
include("ui-messages.jl")

include("library/widgets.jl")
include("library/codemirror.jl")
include("library/markdown.jl")
include("library/latex.jl")
include("library/layout2.jl")

include("render.jl")

end

