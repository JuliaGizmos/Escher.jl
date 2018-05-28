# Getting started

## Installing everything
To install a backend of choice (for example InteractBulma), simply type
 ```
Pkg.clone("https://github.com/piever/InteractBase.jl")
Pkg.clone("https://github.com/piever/InteractBulma.jl")
Pkg.build("InteractBulma");
```

in the REPL.

## Usage

The basic behavior is as follows: Interact

```julia
using InteractBulma
ui = button()
display(ui)
```
