include("helpers/listing.jl")

using Colors

widthlabel(len) =
    hbox("⇤", flex(), string(len) |> fontsize(0.8em), flex(), "⇥") |>
        width(len) |>
        fontcolor("#555")

heightlabel(len) =
    vbox("⤒", flex(), string(len) |> fontsize(0.8em), flex(), "⤓") |>
        height(len) |>
        fontcolor("#555")

xᵗ = Input(220)

function main(window)
    push!(window.assets, "widgets")
    push!(window.assets, "codemirror")
    push!(window.assets, "tex")

    vbox(
        h2("User Guide") |> fontweight(200),
        vskip(1em),
        title(2, "Layout"),

        vskip(1em),
        md"CSS Layouts have been notorious for their complexity when it comes to actually making useful layouts. Centering an element with CSS is often jokingly touted as the hardest problem mankind has ever faced. Luckily, the new [flexbox specification](http://www.w3.org/TR/css-flexbox-1/) by W3C has some principled building blocks for layouts, especially the kind that are routinely used on the web. Escher leverages flexbox and absolute positioning under the hood to provide layout primitives that are easy, and predictible.",
        vskip(1em),
        h1("Sizing a tile: dimensions and padding"),
        vskip(1em),
        md"A tile has an *intrinsic* width and height when created, depending on the size of its content and the size of its containing tile. This is described more in the next few paragraph and the next section. The intrinsic width and height of a tile can be overriden using `width` and `height` functions.",
        listing("""
            box = fillcolor("#555", empty) # An empty gray box
            height(4em, width(8em, box))   # expand to a 4em×8em"""),
        md"""
            The `size` function serves as a shorthand for setting both the width and the height of a tile. For example, `size(8em, 4em, box)` is equivalent to `height(4em, width(8em, box))`. `size` takes three arguments: the width, the height, and the tile to be sized.

            The last argument (the tile) to `width`, `height` and `size` is curried. Hence the following two expressions are equivalent to the above example.
            ```julia
                box |> width(8em) |> height(4em)
                box |> size(8em, 4em)
            ```

            If your tile contains text, the text will be wrapped so that it is bounded by the width of the box. The intrisic height of the tile expands to fit the text.
            """,
        vbox(
            widthlabel(12em),
            width(12em, "One morning, when Gregor Samsa woke from troubled dreams, he found himself transformed in his bed into a horrible vermin.")
            |> fillcolor("#eee"),
            vskip(1em),
            caption("The light gray region marks the extent of the tile. Its intrinsic height expands to accomodate the text.") |> maxwidth(24em)
        ) |> packacross(center),
        "Tread carefully if you want to specify both the width and the height of a tile containing text or other content. If after setting the height the size of the tile is too small to fit its content, the content will overflow. While the actual size of the tile will be set correctly, the text will come out of the boundaries.",
        vbox(
            widthlabel(12em),
            width(12em, "One morning, when Gregor Samsa woke from troubled dreams, he found himself transformed in his bed into a horrible vermin.")
            |> height(5em)
            |> fillcolor("#eee"),
            vskip(1em),
        ) |> packacross(center),

        md"You can pad a tile with some extra space on the edges using the `pad` function. For example, here is a box that has a padding of 2em. The padded region is filled with a darker shade of gray.",
            md"Note: widthlabel is not a function defined in Escher and is defined within this document",
        listing("""
            inner = vbox(
              size(8em, 4em, box),
              widthlabel(8em),
            )
            outer = pad(2em, inner ) |> fillcolor("#bbb") |> size(12em, 8em)
            vbox(outer,
                widthlabel(12em)) |> packacross(center)"""),
        md"""
        Note that padding in Escher actually wraps a tile in another container, unlike CSS. This means you can also add padding to a tile that is already padded.

        Padding is restricted to one or more edges of a tile by passing a vector of edges as the first argument to `pad`. The sides in question are the constants `left`, `right`, `top` and `bottom` -- each denoting the respective edges of the tile.

        For example,
        """,
        listing("paddedWalls = pad([left, right], 2em, size(4em, 4em, box))\n\npaddedWalls |> fillcolor(\"#bbb\") |> hbox |> packitems(center)"),
        vskip(1em),
        h1("Horizontal and vertical layouts"),
        vskip(1em),
        md"Layouts are formed by arranging tiles horizontally and vertically. This is done using `hbox` and `vbox` respectively. `hbox` takes a vector of tiles and lays them out side by side from left to right; while `vbox` takes a vector of tiles and lays them out one on top of the next. The following simple examples illustrate `hbox` and `vbox`.",
        listing("""
            box1 = fillcolor("#555", empty) |> size(4em, 4em)
            box2 = fillcolor("#bbb", empty) |> size(4em, 4em)

            hbox([box1, box2]) |> packitems(center)"""),


        listing("vbox([box1, box2]) |> packacross(center)"),
        md"""
            Since we expect `hbox` and `vbox` to be very commonly used, Escher lets you leave out the square brackets. That is, `hbox([box1, box2])` is equivalent to `hbox(box1, box2)`.

            `hskip` and `vskip` are handy tools to create empty spaces between two tiles in a horizontal and a vertical layout respectively. A `hskip(2em)`, for example between `box1` and `box2` would turn into an empty space of 2em width.""",

        listing("hbox(box1, hskip(2em), box2) |> packitems(center)"),
        md"""You can pad a tile with some extra space on the edges using the `pad` function. For example, here is a box that has a padding of 2em. The padded region is filled with a darker shade of gray.""",
        listing("vbox(box1, vskip(2em), box2) |> packacross(center)"),


        md"""
        Notice that in the above examples we have explicitly set the size of the boxes. However, if not explicitly overriden, the intrinsic *height* of the tiles in a hbox expands to that of the hbox itself, and similarly, the intrinsic *width* of tiles in a vbox expands to that of the parent vbox. 
        """,


        vskip(1em),
        h1("Grow, Shrink and Flex"),
        vskip(1em),

        md"""There are a few ways to expand or shrink tiles to fit the space in a *flex container*. `grow`, `shrink` and `flex` functions let you specify how tiles should resize to fit the space along the *main axis*.

        To expand a tile to fit the remaining space in the container, grow

        when a container is longer than the component elements given lengths, `flex` and `grow` elements retain fill the remaining space, but retain their proportions.
        when a container is shorter than the component elements given lengths, `flex` and `shrink` elements yield space to other elements and retain the constituent proportions. When it gets shorter than that, non-flexible elements yield space. The insides of composite elements are not informed of constraints of a container, so they may not be shrunk or grown accordingly.

        """,
        listing("""
                olive = pad(0.8em,fillcolor("#b76",container(1em,1em)))|>fillcolor("#884")
                #bread = pad([left,right],.5em,fillcolor("#bba",container(12em,3em))) |> fillcolor("#886")
                bread = fillcolor("#bba",container(12em,2em)) 
                lettuce = fillcolor("#ab6",container(14em,0.6em))
                tomato = fillcolor("#d66",container(8em,1.2em))
                cheese = fillcolor("#eea",container(12em,0.6em))
                ham = fillcolor("#c98",container(11em,1.2em)) 

                sandwich = vbox(
                  olive,
                  bread |> shrink,
                  lettuce |> flex,
                  tomato |> flex,
                  cheese |> flex,
                  ham |> grow,
                  bread |> shrink
                ) |> packacross(center)

                sandwich |> height(10.2em)"""),
        md"""
        The following sandwich is made of flexboxes. The ham slice grows, the bread slices and olive are all fixed sizes, and the other toppings are flex boxes. Note how each kind of box changes according to size.
        """,
        # Broken unless you modify the listing above and recompile
        listing("""
                lift(xᵗ) do x
                vbox(                     
                subscribe(slider(0:360), xᵗ),
                  hbox(
                    heightlabel(x*0.05em),
                    sandwich |> height(x*0.05em)
                  )
                )
                end"""),

        vskip(1em),
        h1("Wrapping and packing"),
        vskip(1em),
        md"""Quite often when you have extra space in a container, and you don't want to have flexboxes distorted, you want to retain shape of components, and fill space some other way, or simply align the contents in a different matter. For this, we have a number of ways to pack the contents of a flex container""",
        md"""`packitems` is a wrapper around CSS's [justify-content](https://developer.mozilla.org/en-US/docs/Web/CSS/justify-content) and is used for formatting containers along the flow axis (horizontally in an *hbox*).""",
        md"""`packacross` is a wrapper around CSS's [align-items](https://developer.mozilla.org/en-US/docs/Web/CSS/align-items>) and is used for formatting containers across the flow axis (vertically in an *hbox*). """,
        md"""The properties need to be defined by constructors of type *Packing* as the first argument to a packing method.""",

        # todo: make this into a dropdown box example? Maybe? Or a static table?
        listing("""
                cbox(c) = minwidth(6em,empty) |> fillcolor(c)
                y = empty|>fillcolor(LCHab(75,25,170)) |>
                  minwidth(5em) |> minheight( 0.75em) |>
                  pad( 0.5em) |> fillcolor(LCHab(93.75,0,0))
                #y = cbox(LCHab(75,25,170))
                n = cbox(LCHab(93.75,0,15))
                textfield(w,str) = minwidth(w,(str)) |>
                  fillcolor(LCHab(87.5,0,0)) |>
                  textalign(centertext)
                vbox(
                  textfield(6em,emph("method")) |> fillcolor("white"),
                  hbox(minwidth(6em,emph("packing")),
                    textfield(6em,"packlines"),
                    textfield(6em,"packitems"),
                    textfield(6em,"packacross")),
                  hbox(textfield(6em,"axisstart"),y,y,y),
                  hbox(textfield(6em,"axisend"),y,y,y),
                  hbox(textfield(6em,"center"),y,y,y),
                  hbox(textfield(6em,"baseline"),n,n,y),
                  hbox(textfield(6em,"stretch"),y,n,y),
                  hbox(textfield(6em,"spacebetween"),y,y,n),
                  hbox(textfield(6em,"spacearound"),y,y,n),
                ) |>
                  packitems(center) |>
                  packacross(stretch) |>
                  minheight(20em)
                """),
        # Sandwich example, probably want to delete as it offers little for its weight.
        #= listing("""
            sandwich = vbox(
                olive,
                bread ,
                lettuce,
                tomato,
                cheese,
                ham,
                bread 
            ) |> packacross(center)

            sandwich |> packitems(spacearound) |> height(16em) 
            """), =#
        #= md"""Valid packings and their methods:
        
        for all: `axisstart`, `axisend`, `center`, 

        packacross only: `baseline`

        packacross or packlines: `stretch` 

        packlines or packitems: `spacebetween`, `spacearound` """, # Alternate static documentation (could be useful if the table above breaks) =#
        md"""When you have a container that needs the contents wrapped around because it is constrained in length along the cross-axis, you can do so with `wrap`, and format the wrapping with `packlines`.""",
        listing("""
        swatch(c) = minwidth(4em,empty) |> minheight(4em) |> fillcolor(c)
        gradientPalette(n) = [swatch(c)::Escher.Tile for c=linspace(LCHab(50,75,0),LCHab(50,75,210),n)]

        hbox(gradientPalette(11)) |> 
          packlines(spacearound) |>
          packitems(spacebetween) |>
          packacross(center) |>
          wrap |> fillcolor(LCHab(87.5,0,0)) |>
          width(15em) |> minheight(20em)"""),

        vskip(1em),
        h1("Absolute positioning"),
        vskip(1em)
        ) # |> docpage
end

