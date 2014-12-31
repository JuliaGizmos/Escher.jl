module Canvas

using Patchwork
using Reactive

export Elem

# style helpers
style(elem::Elem, key, val)  = elem & [:style => [key => val]]

# Polymer Setup
const include_file = joinpath(Pkg.dir("Canvas"), "assets", "vulcanized.html")
const custom_elements_html = readall(open(include_file))

function load_custom_elements()
    display(MIME("text/html"), custom_elements_html)
end

try
    load_custom_elements()
catch
end

include("length.jl")
include("util.jl")
include("tiles.jl")
include("layout.jl")
include("looks.jl")
include("render.jl")

end
