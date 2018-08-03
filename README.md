# Escher

Escher has been repurposed to be a metapackage around [Interact.jl](https://github.com/JuliaGizmos/Interact.jl) and other packages for web deployment (so far it includes [Mux.jl](https://github.com/JuliaWeb/Mux.jl) but more things may be added as they become available). Refer to the [Interact documentation](https://juliagizmos.github.io/Interact.jl/latest/) (in particular the [deployment section](https://juliagizmos.github.io/Interact.jl/latest/deploying.html)).

You can replace `using Interact, Mux` with `using Escher`, i.e.:

```julia
using Escher
ui = @manipulate for i in 1:100
    i
end
webio_serve(page("/", req -> ui))
```
