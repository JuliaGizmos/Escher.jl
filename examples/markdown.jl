using Markdown # on v0.3

function main(window)
    markdown = md"""
# Heading 1

$(vskip(1em))
$(hline())
$(vskip(1em))

One morning, when **Gregor Samsa** woke from troubled dreams, he found himself transformed in his bed into a *horrible vermin*.

## Heading 2

Code block:
```julia

function foo()
    1+1
end
```

### Heading 3

Here is a quote:

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
