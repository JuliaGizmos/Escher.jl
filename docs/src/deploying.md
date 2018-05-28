# Deploying the web app

Escher works with the following frontends:

- [Juno](http://junolab.org) - The hottest Julia IDE
- [IJulia](https://github.com/JuliaLang/IJulia.jl) - Jupyter notebooks (and Jupyter Lab) for Julia
- [Blink](https://github.com/JunoLab/Blink.jl) - An [Electron](http://electron.atom.io/) wrapper you can use to make Desktop apps
- [Mux](https://github.com/JuliaWeb/Mux.jl) - A web server framework

## Displaying a widget

```julia
using Escher
ui = button()
display(ui)
```

Note that `display` works in a [Jupyter notebook](https://github.com/JuliaLang/IJulia.jl) or in [Atom/Juno IDE](https://github.com/JunoLab/Juno.jl).
InteractBase can also be deployed in Jupyter Lab, but that requires installing an extension first:

```julia
cd(Pkg.dir("WebIO", "assets"))
;jupyter labextension install webio
;jupyter labextension enable webio/jupyterlab_entry
```

To deploy the app as a standalone Electron window, one would use [Blink.jl](https://github.com/JunoLab/Blink.jl):

```julia
using Blink
w = Window()
body!(w, ui);
```

The app can also be served in a webpage via [Mux.jl](https://github.com/JuliaWeb/Mux.jl):

```julia
using Mux
webio_serve(page("/", req -> ui), rand(8000:9000)) # serve on a random port
```
