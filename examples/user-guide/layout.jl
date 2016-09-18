include("helpers/listing.jl")
using Colors

function main(window)
    push!(window.assets, "widgets")
    push!(window.assets, "codemirror")
    push!(window.assets, "tex")

    colors = ["violet", "blue", "green", "yellow", "orange", "red"]
    colortile(c, w, h) = fillcolor(c, size(w, h, empty))
    vbox(
        title(3, "Layout"),
        md"""Escher UI's are built using Tiles. These Tiles can be put together in
        several ways to allow for several layouts.

        We see a few examples on how to create layouts using Escher here. For the
        purposes of these examples let us assume the use following tiles which are
        filled with 6 different colors - violet, blue, green, yellow, orange, red.
        These can be replaced by any Tile created using the Content API.""",

        h1("Sizes of Tiles"),
        md"""`width` sets the width and `height` sets the height of a tile.

        To create an empty tile of 4em x 4em that is filled with red""",
        listing("""
        widetile = Escher.width(4em, empty)
        squaretile = Escher.height(4em, widetile)
        fillcolor("red", squaretile)
        """,
            fillcolor("red", Escher.height(4em, width(4em, empty)))
        ),
        md"""We could use the `size` function, which sets the width and height of a tile.

        Making our code a bit more generic and using `size`""",
        listing("""
        colortile(c, w, h) = fillcolor(c, size(w, h, empty))
        colortile("red", 4em, 4em)
        """,
            colortile("red", 4em, 4em)
        ),
        md"We now have a way of creating tiles of our required dimensions. Now lets
        look at how we can lay these tiles out!",
        h1("Padding"),
        md"""Often we require some amount of padding around our tiles. To do this
        for an individual tile, we can use `pad`. You can a also pass an array of
        sides to selectively pad them. `left`, `right`, `top`, and `bottom` are
        possible choices.
        Extending our colortile example...""",
        listing("""
        colortile(c, w, h) = fillcolor(c, size(w, h, empty))
        redtile = colortile("red", 4em, 4em)
        paddedtile = redtile |> pad(2em)
        vbox(
            vbox("Normal tile", redtile),
            vbox("Tile with padding on allsides", paddedtile),
            hbox(
                redtile |> pad([left], 2em),
                "Only left padding",
                redtile |> pad([right], 2em),
                "Only right padding",
            ),
            vbox(
                "Only bottom padding",
                redtile |> pad([bottom], 2em),
                "Only top padding",
                redtile |> pad([top], 2em),
            ),
        )
        """,
        ),
        vskip(2em),
        h1("Creating Flows"),
        md"""Putting together flows is how UIs are built in Escher. Flows are created
        by putting together tiles using `flow`. `flow` creates a flow container with
        the components and decides what axis the components will
        be laid out on, i.e, `horizontal` or `vertical`.""",
        h3(md"Horizontal Flow - `hbox`"),
        md"""To obtain a horizontal layout of tiles, use `hbox`. `hbox` creates a
        horizontal flow of all the tiles passed to it, i.e, the main axis is the
        horizontal axis. `hbox` can also take arguments as an array of tiles.""",
        listing("""
        colors = ["violet", "blue", "green", "yellow", "orange", "red"]
        hbox(
            map(
                c -> colortile(c, 4em, 4em),
                colors
            )
        )
        """,
            hbox(
                map(
                c -> colortile(c, 4em, 4em),
                colors
                )
            )
        ),
        h3(md"Vertical Flow - `vbox`"),
        md"""To obtain a vertical layout of tiles, use `vbox`. `vbox` creates a
        vertical flow of all the tiles passed to it, i.e, the main axis is the
        vertical axis. `vbox` can also take arguments as an array of tiles.""",
        listing("""
        colors = ["violet", "blue", "green", "yellow", "orange", "red"]
        vbox(
            map(
                c -> colortile(c, 4em, 4em),
                colors
            )
        )
        """,
            vbox(
                map(
                c -> colortile(c, 4em, 4em),
                colors
                )
            )
        ),
        h3(md"Combine `vbox` and `hbox` to make complex layouts!"),
        listing("""
        colortile(c, w, h) = fillcolor(c, size(w, h, empty))
        colors = ["violet", "blue", "green", "yellow", "orange", "red"]
        colortiles = map(
            c -> colortile(c, 4em, 4em),
            colors
        )
        vcolorset = vbox(colortiles)
        hcolorset = hbox(colortiles[2:end])
        hbox(
            vcolorset,
            hcolorset
        )
        """
        ),
        h3(md"Growing tiles"),
        md"""
        Tiles can be grown to fill remaining space existing in a flow container.
        We use `grow` to create tiles that can be grown and specify a relative factor
        to decide on their rate of growth in comparison to other tiles that can
        grow. Tiles are grown only if the elements do not occupy the complete
        space along the main axis of the container.
        """,
        listing("""
        colors = ["violet", "blue", "green", "yellow", "orange", "red"]
        colortiles = map(
            c -> colortile(c, 4em, 4em),
            colors
        )
        hbox(
            colortiles[1:3]...,
            grow(2, colortiles[4]),
            colortiles[5],
            grow(1, colortiles[end]),
        )
        """
        ),
        h3(md"Shrinking tiles"),
        md"""
        Tiles can be shrinked to fit into the space existing in a flow container.
        We use `shrink` to create tiles that can be shrunk and specify a relative factor
        to decide on the rate at which they are shrunk in comparison to other tiles that can
        be shrunk. Tiles are shrunk only if the elements occupy more than the complete
        space along the main axis of the container.
        """,
        listing("""
        colors = ["violet", "blue", "green", "yellow", "orange", "red"]
        colortiles = map(
            c -> colortile(c, 8em, 4em),
            colors
        )
        hbox(
            colortiles[1:3]...,
            shrink(2, colortiles[4]),
            colortiles[5],
            shrink(1.5, colortiles[end])
        )
        """
        ),
        h3(md"Flexing tiles"),
        md"""To create a tile that will either shrink/grow to fill the remaining
        space in a flow container, use `flex`.""",
        listing("""
        colors = ["violet", "blue", "green", "yellow", "orange", "red"]
        colortiles = map(
            c -> colortile(c, 4em, 4em),
            colors
        )
        hbox(
            colortiles[1:3]...,
            flex(colortiles[4]),
            colortiles[5:end]...,
        )
        """
        ),
        h1(md"Packing spaces"),
        md"""
        While creating flows, we have several ways of packing the contents
        so as to manage space. They are :

        - `axisstart`
        - `axisend`
        - `center`
        - `spacebetween`
        - `spacearound`
        - `stretch`
        - `baseline`

        """,
        h3(md"Packing items along the main axis"),
        md"""
        We can use `packitems` to specify what part of the main axis we want to
        pack our items across. `baseline` and `stretch` cannot be used here.
        """,
        listing("""
        packings = [axisstart, axisend, center, spacebetween, spacearound]
        vbox(
            map(
                p -> vbox(
                string(typeof(p)),
                hbox(colortiles) |> packitems(p)
                ),
                packings
            )
        )
        """
        ),
        h3(md"Packing items along the cross axis"),
        md"""
        We can use `packacross` to specify what part of the cross axis we want to
        pack our items across. `spacearound` and `spacebetween` cannot be used here.
        """,
        listing("""
        packings = [axisstart, axisend, center, stretch]
        vbox(
            map(
                p -> vbox(
                string(typeof(p)),
                vbox(colortiles) |> packacross(p)
                ),
                packings
            )
        )
        """),
        h3(md"Packing items as lines"),
        md"""
        Pack wrapped lines of tiles across the cross axis.
        """,
        listing("""
        packings = [axisstart, axisend, center, spacearound, spacebetween, stretch]
        vbox(
            map(
                p -> vbox(
                string(typeof(p)),
                hbox(colortiles) |> packlines(p)
                ),
                packings
            )
        )
        """
        )
        ) |> pad(2em)
end
