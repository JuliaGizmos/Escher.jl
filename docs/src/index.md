# InteractBase

InteractBase aims to be the successor of [Interact](https://github.com/JuliaGizmos/Interact.jl) and [InteractNext](https://github.com/JuliaGizmos/InteractNext.jl).

It allows to create small GUIs in Julia based on web technology. These GUIs can be deployed in jupyter notebooks, in the Juno IDE plot pane, in an Electron window or in the browser.

To understand how to use it go through the [Tutorial](@ref). The tutorial is also available [here](https://github.com/piever/InteractBase.jl/blob/master/docs/examples/tutorial.ipynb) as a Jupyter notebook.

A list of available widget can be found at [API reference](@ref)

InteractBase (together with [Vue](https://github.com/JuliaGizmos/Vue.jl) and [WebIO](https://github.com/JuliaGizmos/WebIO.jl)) provides the logic that allows the communication between Julia and Javascript and the organization of the widgets. To style those widgets you will need to load one CSS framework.

## CSS frameworks

Two CSS frameworks are available, based one on [Bulma](https://bulma.io/) and the other on [UIkit](https://getuikit.com/). Choosing one or the other is mainly a matter of taste. Bulma is my personal recommendation as it is a pure CSS framework (no extra Javascript), which leaves Julia fully in control of manipulating the DOM (which in turn means less surface area for bugs). To install the corresponding package type:

```julia
Pkg.clone("https://github.com/piever/InteractBulma.jl")
Pkg.build("InteractBulma");
```

or

```julia
Pkg.clone("https://github.com/piever/InteractUIkit.jl")
Pkg.build("InteractUIkit");
```

in the REPL.

To load one of them simply do, for example:

```julia
using InteractBulma
```

To change backend in the middle of the session simply do:

```julia
settheme!(Bulma())
```

or

```julia
settheme!(UIkit())
```

## Deploying the web app

InteractBase works with the following frontends:

- [Juno](http://junolab.org) - The hottest Julia IDE
- [IJulia](https://github.com/JuliaLang/IJulia.jl) - Jupyter notebooks (and Jupyter Lab) for Julia
- [Blink](https://github.com/JunoLab/Blink.jl) - An [Electron](http://electron.atom.io/) wrapper you can use to make Desktop apps
- [Mux](https://github.com/JuliaWeb/Mux.jl) - A web server framework


See [Displaying a widget](@ref) for instructions.
