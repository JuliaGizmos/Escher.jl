# Escher

Composable web UIs in Julia

###Development

This package is not ready for mainstream use. However, if you want to help develop this package, use the following instructions to get started: 

Currently Escher works with Julia v0.3.

_In a Julia REPL_

```julia
Pkg.clone("https://github.com/shashi/Escher.jl.git")
```

_On the command line, within the `assets/` subdirectory_

```sh
npm install -g bower
bower install
```

_On the command line, from within the `Escher.jl/examples` directory_

```sh
../bin/escher --serve
```

and navigate to `http://localhost:5555/layout.jl` (or `http://localhost:5555/<any-other-example-file.jl>`)

