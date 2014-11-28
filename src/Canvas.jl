module Canvas

using Patchwork
using Reactive

# style helpers
style(elem::Elem, key, val)  = elem & [:style => [key => val]]

# CSS Setup
function load_custom_elements()
    layoutcss = joinpath(Pkg.dir("Canvas"), "assets", "vulcanized.html")
    display(MIME("text/html"), readall(open(layoutcss)))
end

load_custom_elements()

include("length.jl")
include("util.jl")
include("tiles.jl")
include("layout.jl")
include("looks.jl")
include("render.jl")

end
