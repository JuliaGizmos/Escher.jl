using Color

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

@api bordercolor => BorderColor <: Tile begin
    typedarg(sides::AbstractArray=allsides)
    arg(color::ColorValue)
    curry(tile::Tile)
end
render(t::BorderColor, state) =
    render(t.tile, state) & (
        mapparts(
            allsides, t.sides, "border", "Color", render_color(t.color)
        ) |> style
    )

@api borderwidth => BorderWidth <: Tile begin
    typedarg(sides::AbstractArray=allsides)
    arg(width::Length)
    curry(tile::Tile)
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

@api borderstyle => BorderStyle <: Tile begin
    typedarg(sides::AbstractArray=allsides)
    arg(style::StrokeStyle)
    curry(tile::Tile)
end
render(t::BorderStyle, state) =
    render(t.tile, state) &
        style(mapparts(allsides, t.sides, "border", "Style", name(t.style)))

border(
    sides::AbstractArray,
    style::StrokeStyle,
    width::Length,
    color::ColorValue,
    tile
) =
    borderstyle(sides, style,
        borderwidth(sides, width,
            bordercolor(sides, color, tile)))

border(sides::AbstractArray, style, width, color) =
    tile -> border(sides, style, width, color, tile)

border(style::StrokeStyle, width::Length, color::ColorValue, tile) =
    borderstyle(allsides, style,
        borderwidth(allsides, width,
            bordercolor(allsides, color, tile)))

border(style::StrokeStyle, width, color) =
    tile -> border(style, width, color, tile)

const default_border_color = RGB(0.6, 0.6, 0.6)

hline(;style=solid, width=1px, color=default_border_color) =
    border([bottom], style, width, color, empty)

vline(;style=solid, width=1px, color=default_border_color) =
    border([left], style, width, color, empty)

## RoundRects

const allcorners = Corner[]
@api roundcorner => RoundedRect <: Tile begin
    typedarg(corners::AbstractArray=allcorners)
    arg(radius::Length)
    curry(tile::Tile)
end

render(t::RoundedRect, state) =
    render(t.tile, state) &
        style(mapparts(allcorners, t.corners, "border", "Radius", t.radius))


## Box shadow

@api shadow => Shadow <: Tile begin
    curry(tile::Tile)
    kwarg(inset::Bool=false)
    kwarg(offset::(@compat Tuple{Length, Length})=(0px, 0px))
    kwarg(blur_radius::Length=5px)
    kwarg(spread_radius::Length=5px)
    kwarg(color::ColorValue=color("black"))
end

## Fill color

@api fillcolor => FillColor <: Tile begin
    arg(color::ColorValue)
    curry(tile::Tile)
end

render(t::FillColor, state) =
    render(t.tile, state) & style(@d(:backgroundColor => render_color(t.color)))

