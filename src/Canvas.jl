module Canvas

using Patchwork
using Reactive

# style helpers
style(elem::Elem, key, val)  = elem & [:style => [key => val]]

include("length.jl")
include("util.jl")
include("tiles.jl")
include("layout.jl")
include("looks.jl")

end
