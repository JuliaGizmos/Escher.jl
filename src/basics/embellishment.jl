using Color

export noborder,
       dotted,
       dashed,
       solid,
       strokewidth,
       border,
       bordercolor,
       hline, vline,
       roundcorner,
       shadow,
       fillcolor

render_color(c) = string("#" * hex(c))

## Borders

const allsides = Side[]

@api bordercolor => BorderColor <: Tile begin
    typedarg(sides::AbstractArray=allsides)
    arg(color::ColorValue)
    curry(tile::Tile)
end
render(t::BorderColor) =
    render(t.tile) & [:style => mapparts(allsides, t.sides, "border", "Color", render_color(t.color))]

@api borderwidth => BorderWidth <: Tile begin
    typedarg(sides::AbstractArray=allsides)
    arg(width::Length)
    curry(tile::Tile)
end
render(t::BorderWidth) =
    render(t.tile) & [:style => mapparts(allsides, t.sides, "border", "Width", t.width)]

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

@api borderstyle => BorderStyle begin
    typedarg(sides::AbstractArray=allsides)
    arg(style::StrokeStyle)
    curry(tile::Tile)
end
render(t::BorderStyle) =
    render(t.tile) & [:style => mapparts(allsides, t.sides, "border", "Style", name(t.style))]

border(sides::AbstractArray, style::StrokeStyle, width::Length, color::ColorValue, tile) =
    borderstyle(sides, style, borderwidth(sides, width, bordercolor(sides, color, tile)))

border(sides::AbstractArray, style, width, color) =
    tile -> border(sides, style, width, color, tile)

border(style::StrokeStyle, width::Length, color::ColorValue, tile) =
    borderstyle(allsides, style, borderwidth(allsides, width, bordercolor(allsides, color, tile)))

border(style::StrokeStyle, width, color) =
    tile -> border(style, width, color, tile)

hline(style=solid, width=1px, color=color("lightgray")) =
    border([bottom], style, width, color, height(empty, 0px))

vline(style=solid, width=1px, color=color("lightgray")) =
    border([bottom], style, width, color, width(empty, 0px))

## RoundRects

const allcorners = Corner[]
@api roundcorner => RoundedRect <: Tile begin
    typedarg(corners::AbstractArray=allcorners)
    arg(radius::Length)
    curry(tile::Tile)
end

render(t::RoundedRect) =
    render(t.tile) &
        [:style => mapparts(allcorners, t.corners, "border", "Radius", t.radius)]


## Box shadow

@api shadow => Shadow <: Tile begin
    curry(tile::Tile)
    kwarg(inset::Bool=false)
    kwarg(offset::(Length, Length)=(0px, 0px))
    kwarg(blur_radius::Length=5px)
    kwarg(spread_radius::Length=5px)
    kwarg(color::ColorValue=color("black"))
end

## Fill color

@api fillcolor => FillColor <: Tile begin
    arg(color::ColorValue)
    curry(tile::Tile)
end

render(t::FillColor) =
    render(t.tile) & [:style => [:backgroundColor => render_color(t.color)]]

