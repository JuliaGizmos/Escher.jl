# Escher

[![Join the chat at https://gitter.im/shashi/Escher.jl](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/shashi/Escher.jl?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

A toolkit for great-looking interactive Web UIs in Julia.

Read [the overview](https://shashi.github.io/Escher.jl/).

## Installation

In a Julia REPL, run:

```julia
Pkg.add("Escher")
```

You might want to link escher executable to `/usr/local/bin` or somewhere in your `PATH`:

```sh
ln -s ~/.julia/v0.4/Escher/bin/escher /usr/local/bin/
```

## Usage

From a directory in which you want to serve Escher UI files, run:

```
<Escher-package-path/bin>/escher --serve
```

This will bring up a web server on port 5555. The `examples/` directory in `Pkg.dir("Escher")` contains a few examples. After runnnig the escher server from this directory, you can visit `http://localhost:5555/<example-file.jl>` to see the output of `<example-file.jl>`. Note that examples containing plots may take a while to load the first time you visit them.

See `escher --help` for other options to the exectuable.
