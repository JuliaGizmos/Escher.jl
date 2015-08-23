include("helpers/page.jl")
include("helpers/doc.jl")

widthlabel(len) =
    hbox("⇤", flex(), string(len) |> fontsize(0.8em), flex(), "⇥") |>
        width(len) |>
        fontcolor("#555")

intro = md"""
$(h2("User Guide") |> fontweight(200))
$(vskip(1em))
$(title(2, "Layout"))

$(vskip(1em))

CSS Layouts have been notorious for their complexity when it comes to actually making useful layouts. Centering an element with CSS is often jokingly touted as the hardest problem mankind has ever faced. Luckily, the new [flexbox specification](http://www.w3.org/TR/css-flexbox-1/) by W3C has some principled building blocks for layouts, especially the kind that are routinely used on the web. Escher leverages flexbox and absolute positioning under the hood to provide layout primitives that are easy, and predictible.

$(vskip(1em))
# Sizing a tile: dimensions and padding
$(vskip(1em))

A tile has an *intrinsic* width and height when created, depending on the size of its content and the size of its containing tile. This is described more in the next few paragraph and the next section. The intrinsic width and height of a tile can be overriden using `width` and `height` functions.

```julia
    box = fillcolor("#555", empty) # An empty gray box
    height(4em, width(8em, box))   # expand to a 5em×5em
```

results in:

$(begin
    box = fillcolor("#555", empty)
    hbox(height(4em, width(8em, box))) |> packitems(center) |> fig
end)


The `size` function serves as a shorthand for setting both the width and the height of a tile. For example, `size(8em, 4em, box)` is equivalent to `height(4em, width(8em, box))`. `size` takes three arguments: the width, the height, and the tile to be sized.

The last argument (the tile) to `width`, `height` and `size` is curried. Hence the following two expressions are equivalent to the above example.
```julia
    box |> width(8em) |> height(4em)
    box |> size(8em, 4em)
```

If your tile contains text, the text will be wrapped so that it is bounded by the width of the box. The intrisic height of the tile expands to fit the text.

$(
vbox(
    widthlabel(12em),
    width(12em, "One morning, when Gregor Samsa woke from troubled dreams, he found himself transformed in his bed into a horrible vermin.")
    |> fillcolor("#eee"),
    vskip(1em),
    caption("The light gray region marks the extent of the tile. Its intrinsic height expands to accomodate the text.") |> maxwidth(24em)
) |> packacross(center) |> fig

)

Tread carefully if you want to specify both the width and the height of a tile containing text or other content. If after setting the height the size of the tile is too small to fit its content, the content will overflow. While the actual size of the tile will be set correctly, the text will come out of the boundaries.

$(
vbox(
    widthlabel(12em),
    width(12em, "One morning, when Gregor Samsa woke from troubled dreams, he found himself transformed in his bed into a horrible vermin.")
    |> height(5em)
    |> fillcolor("#eee"),
    vskip(1em),
) |> packacross(center) |> fig

)

You can pad a tile with some extra space on the edges using the `pad` function. For example, here is a box that has a padding of 2em. The padded region is filled with a darker shade of gray.

```julia
    inner = size(8em, 4em, box)
    outer = pad(2em, box) |> fillcolor("#bbb")
```
$(begin
    inner = vbox(size(8em, 4em, box),
                 widthlabel(8em),
            )
    outer = pad(2em, size(8em, 4em, box)) |> fillcolor("#bbb") |> size(12em, 8em) |> hbox
    vbox(outer,
        widthlabel(12em)) |> packacross(center) |> fig
end)

Note that padding in Escher actually wraps a tile in another container, unlike CSS. This means you can also add padding to a tile that is already padded.

Padding is restricted to one or more edges of a tile by passing a vector of edges as the first argument to `pad`. The sides in question are the constants `left`, `right`, `top` and `bottom` -- each denoting the respective edges of the tile.

For example,

```julia
    pad([left, right], 2em, size(4em, 4em, box))
```

$(begin
        pad([left, right], 2em, size(4em, 4em, box)) |> fillcolor("#bbb") |> hbox |> packitems(center) |> fig
end)

$(vskip(1em))

# Horizontal and vertical layouts
$(vskip(1em))

Layouts are formed by arranging tiles horizontally and vertically. This is done using `hbox` and `vbox` respectively. `hbox` takes a vector of tiles and lays them out side by side from left to right; while `vbox` takes a vector of tiles and lays them out one on top of the next. The following simple examples illustrate `hbox` and `vbox`.

```julia

    box1 = fillcolor("#555", empty) |> size(4em, 4em)
    box2 = fillcolor("#bbb", empty) |> size(4em, 4em)

    hbox([box1, box2])
```

$(begin
    box1 = fillcolor("#555", empty) |> size(4em, 4em)
    box2 = fillcolor("#bbb", empty) |> size(4em, 4em)
    hbox([box1, box2]) |> packitems(center) |> fig
end)

```julia
    vbox([box1, box2])
```
$(
    vbox([box1, box2]) |> packacross(center) |> fig
)

Since we expect `hbox` and `vbox` to be very commonly used, Escher lets you leave out the square brackets. That is, `hbox([box1, box2])` is equivalent to `hbox(box1, box2)`.

`hskip` and `vskip` are handy tools to create empty spaces between two tiles in a horizontal and a vertical layout respectively. A `hskip(2em)`, for example between `box1` and `box2` would turn into an empty space of 2em width.

```julia
    hbox(box1, hskip(2em), box2)
```

$(hbox(box1, hskip(2em), box2) |> packitems(center) |> fig)

```julia
    vbox(box1, vskip(2em), box2)
```

$(vbox(box1, vskip(2em), box2) |> packacross(center) |> fig)


Notice that in the above examples we have explicitly set the size of the boxes. However, if not explicitly overriden, the intrinsic *height* of the tiles in a hbox expands to that of the hbox itself, and similarly, the intrinsic *width* of tiles in a vbox expands to that of the parent vbox. 



$(vskip(1em))
# Grow, Shrink and Flex
$(vskip(1em))

There are a few ways to expand or shrink tiles to fit the space in a *flex container*. `grow`, `shrink` and `flex` functions let you specify how tiles should resize to fit the space along the *main axis*.

To expand a tile to fit the remaining space in the container, grow

$(vskip(1em))
# Wrapping and packing
$(vskip(1em))

$(vskip(1em))
# Absolute positioning
$(vskip(1em))
"""

function main(window)
    docpage(intro)
end

