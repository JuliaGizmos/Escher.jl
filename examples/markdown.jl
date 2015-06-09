using Markdown # on v0.3

function main(window)
    push!(window.assets, "codemirror")
    markdown = md"""
# Heading 1

$(vskip(1em))
$(hline())
$(vskip(1em))

One morning, when **Gregor Samsa** woke from troubled dreams, he found himself transformed in his bed into a *horrible vermin*.

## Heading 2

Here is some code:

```julia
function fib(x)
    if x in [0, 1]
        x
    else
        fib(x-1) + fib(x-2)
    end
end
```

### Heading 3


> when you don't create things, you become defined by your tastes rather than ability. your tastes only narrow & exclude people. so create.
-- whytheluckystiff

## Heading 2

You can also interpolate other Escher-renderable objects (including plots and Canvas gfraphics)

$(title(3, "I was interpolated here"))

"""

    # You can now use the markdown object in other Escher compositions
    # e.g. In this layout:
    hbox(flex(),
        vbox(title(2, "Markdown example"), vskip(1em), markdown) |>
            maxwidth(40em), flex())
end
