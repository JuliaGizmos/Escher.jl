# Escher

Composable web UIs in Julia

###Development

This package is not ready for mainstream use. However, if you want to help develop this package, use the following instructions to get started: 

Currently Escher works with Julia v0.3.

_In a Julia REPL_

```julia
Pkg.clone("git@github.com:one-more-minute/Hiccup.jl.git")
Pkg.clone("git@github.com:one-more-minute/Mux.jl.git")
Pkg.checkout("Lazy")
Pkg.add("WebSockets")
Pkg.add("Markdown")
Pkg.checkout("Markdown")

Pkg.clone("git@github.com:shashi/Escher.jl.git")
```

_On the command line, within the `assets/` subdirectory_

```sh
npm install -g bower
bower install
```

_On the command line, from within the `Escher.jl/examples` directory_

```sh
../bin/escherd
```

and navigate to `http://localhost:8000/layout.jl`

This library uses `html import` functionality that is not enabled by default in Firefox. Either use Chrome, or enable the `dom.webcomponents.enabled` setting in Firefox's `about:config`. 


