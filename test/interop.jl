using Escher
using Gadfly

# See if using Gadfly initializes interop
@test length(methods(drawing)) > 2
@test method_exists(drawing, (Measures.Measure, Measures.Measure, Any))
@test method_exists(convert, (Type{Escher.Tile}, Gadfly.Plot))
