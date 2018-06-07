# Escher

A library for web-based UI design in Julia, based on [JuliaGizmos](https://github.com/JuliaGizmos) packages.

In particular it combines:

- [Interact](https://github.com/JuliaGizmos/Interact.jl) to create and style interactive HTML5 widgets from Julia

- [Observables](https://github.com/JuliaGizmos/Observables.jl) to store the value of each widget in an `Observable`, a `Ref` whose changes can be used to update other parts of the UI

- [WebIO](https://github.com/JuliaGizmos/WebIO.jl) to deploy the UI in an Electron window via Blink, in the Juno IDE plot pane and in the browser via Mux, as well as in Jupyter notebook and Jupyter lab (meaning that the same code used in the Juno plot pane or in a notebook can be deployed as a web app)

- [CSSUtil](https://github.com/JuliaGizmos/CSSUtil.jl) to manage the layout of the app
