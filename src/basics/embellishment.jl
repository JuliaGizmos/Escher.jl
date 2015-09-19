using Colors

export noborder,
       dotted,
       dashed,
       solid,
       border,
       bordercolor,
       borderwidth,
       borderstyle,
       hline, vline,
       roundcorner,
       shadow,
       fillcolor

## Borders

const allsides = Side[]

@api bordercolor => (BorderColor <: Tile) begin
    doc(md"""Set the border color. Note that you need to set the `borderwidth` as
    well for the border to actually appear.""")
    typedarg(
        sides::AbstractArray=allsides,
        doc=md"""An array of sides to set the border color for. Valid values are
               `left`, `right`, `top` and `bottom`. By default the border color
               is set for all sides."""
    )
    arg(color::Color, doc="The color.")
    curry(tile::Tile, doc="The tile to border.")
end
render(t::BorderColor, state) =
    render(t.tile, state) & (
        mapparts(
            allsides, t.sides, "border", "Color", render_color(t.color)
        ) |> style
    )

@api borderwidth => (BorderWidth <: Tile) begin
    doc("Set the border width.")
    typedarg(
        sides::AbstractArray=allsides,
        doc=md"""An array of sides to set the border width for. Valid values are
               `left`, `right`, `top` and `bottom`. By default the border width
               is set for all sides."""
    )
    arg(width::Length, doc="The width.")
    curry(tile::Tile, doc="The tile to border.")
end
render(t::BorderWidth, state) =
    render(t.tile, state) &
        style(mapparts(allsides, t.sides, "border", "Width", t.width))

abstract StrokeStyle

@terms StrokeStyle begin
    noborder => NoStroke
    dotted => Dotted
    dashed => Dashed
    solid => Solid
end

name(::NoStroke) = "none"
name(::Solid) = "solid"
name(::Dotted) = "dotted"
name(::Dashed) = "dashed"

@api borderstyle => (BorderStyle <: Tile) begin
    doc(md"""Set the border style. Note that you need to set the `borderwidth`
             as well for the border to actually appear.""")
    typedarg(
        sides::AbstractArray=allsides,
        doc=md"""An array of sides to set the border style for. Valid values are
               `left`, `right`, `top` and `bottom`. By default the border style
               is set for all sides."""
        )
    arg(
        style::StrokeStyle,
        doc=md"""The border style. Valid values are `noborder`, `dotted`, `dashed`
               and `solid`."""
    )
    curry(tile::Tile, doc="The tile to border.")
end
render(t::BorderStyle, state) =
    render(t.tile, state) &
        style(mapparts(allsides, t.sides, "border", "Style", name(t.style)))

border(
    sides::AbstractArray,
    style::StrokeStyle,
    width::Length,
    color::Color,
    tile
) =
    borderstyle(sides, style,
        borderwidth(sides, width,
            bordercolor(sides, color, tile)))

border(sides::AbstractArray, style, width, color) =
    tile -> border(sides, style, width, color, tile)

border(style::StrokeStyle, width::Length, color::Color, tile) =
    borderstyle(allsides, style,
        borderwidth(allsides, width,
            bordercolor(allsides, color, tile)))

border(style::StrokeStyle, width, color) =
    tile -> border(style, width, color, tile)

@apidoc border => (BorderStyle <: Tile) begin
    doc("A helper function for setting border properties.")
    typedarg(sides::AbstractArray=allsides, doc="An array of sides to set the border for. Valid values are `left`, `right`, `top` and `bottom`. By default the border is set for all sides.")
    arg(style::StrokeStyle, doc="The border style. Valid values are `noborder`, `dotted`, `dashed` and `solid`.")
    arg(width::Length, doc="The width.")
    arg(color::Color, doc="The color.")
    curry(tile::Tile, doc="The tile to border.")
end
const default_border_color = RGB(0.6, 0.6, 0.6)

hline(;style=solid, width=1px, color=default_border_color) =
    border([bottom], style, width, color, empty)

@apidoc hline => (BorderStyle <: Tile) begin
    doc("Create a horizontal line. Returns a bordered tile of height 0.")
    kwarg(style::StrokeStyle, doc="The line style. Valid values are `noborder`, `dotted`, `dashed` and `solid`.")
    kwarg(width::Length, doc="The width.")
    kwarg(color::Color, doc="The color.")
end

vline(;style=solid, width=1px, color=default_border_color) =
    border([left], style, width, color, empty)

@apidoc vline => (BorderStyle <: Tile) begin
    doc("Create a vertical line. Returns a bordered tile of width 0.")
    kwarg(style::StrokeStyle, doc="The line style. Valid values are `noborder`, `dotted`, `dashed` and `solid`.")
    kwarg(width::Length, doc="The width.")
    kwarg(color::Color, doc="The color.")
end

## RoundRects

const allcorners = Corner[]
@api roundcorner => (RoundedRect <: Tile) begin
    doc("Round the corner of a tile.")
    typedarg(corners::AbstractArray=allcorners, doc=md"An array of corners to set the rounding for. By default, all corners are rounded. Valid corners are `topleft`,`midtop`,`topright`,`midleft`,`middle`,`midright`,`bottomleft`,`midbottom` and `bottomright`.")
    arg(radius::Length, doc="The radius.")
    curry(tile::Tile, doc="A tile.")
end

render(t::RoundedRect, state) =
    render(t.tile, state) &
        style(mapparts(allcorners, t.corners, "border", "Radius", t.radius))


## Box shadow

@api shadow => (Shadow <: Tile) begin
    doc("Show a shadow around a tile.")
    curry(tile::Tile, doc="A tile.")
    kwarg(inset::Bool=false, doc="Set whether the shadow falls inward or outward")
    kwarg(offset::(@compat Tuple{Length, Length})=(0px, 0px), doc="The offset. Displaces the shadow relative to the tile.")
    kwarg(blur_radius::Length=5px, doc="The radius for blurring.")
    kwarg(spread_radius::Length=5px, doc="The radius for spreading.")
    kwarg(color::Color=parse(Colorant,"black"), doc="Base color of the shadow.")
end

## Fill color

@api fillcolor => (FillColor <: Tile) begin
    doc("Fill a tile with a color.")
    arg(color::Color, doc="The color.")
    curry(tile::Tile, doc="The tile.")
end

render(t::FillColor, state) =
    render(t.tile, state) & style(@d(:backgroundColor => render_color(t.color)))
