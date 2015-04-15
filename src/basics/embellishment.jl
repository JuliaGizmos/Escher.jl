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

abstract BorderProperty

abstract StrokeStyle <: BorderProperty

@terms StrokeStyle begin
    noborder => NoStroke
    dotted => Dotted
    dashed => Dashed
    solid => Solid
end

propname(::StrokeStyle) = "Style"

name(::NoStroke) = "none"
name(::Solid) = "solid"
name(::Dotted) = "dotted"
name(::Dashed) = "dashed"


@api strokewidth => StrokeWidth <: BorderProperty begin
    arg(thickness::Length)
end

propname(::StrokeWidth) = "Width"
name(p::StrokeWidth) = p.thickness


@api bordercolor => BorderColor <: BorderProperty begin
    arg(color::ColorValue)
end

propname(::BorderColor) = "Color"
name(p::BorderColor) = render_color(p.color)


@api border => WithBorder{P <: BorderProperty} <: Tile begin
    typedarg(sides::AbstractArray=Side[])
    typedarg(prop::P)
    curry(tile::Tile)
end

render(t::WithBorder) =
    render(t.tile) &
        (isempty(t.sides) ? # Apply padding to all sides if none specified
                [:style => ["border" * propname(t.prop) => name(t.prop)]] :
                [:style => ["border" * name(s) * propname(t.prop) => name(t.prop) for s=t.sides]])


# Autopromote some types to border property
border(sides::AbstractArray, p::Length, x) =
    WithBorder(sides, strokewidth(p), x)
border(sides::AbstractArray, p::ColorValue, x) =
    WithBorder(sides, bordercolor(p), x)
border(p::Union(ColorValue, Length), x) =
    border(Side[], p, x)
border(sides::AbstractArray, ps::BorderProperty...) =
    t -> foldl((acc, p) -> border(sides, p, acc), t, ps)
border(ps::BorderProperty...) =
    border(Side[], ps...)

line(args...) = border([bottom], color("lightgray"), empty) |>
    x -> border([bottom], solid, x) |>
    x -> border([bottom], 1px, x) |>
    border([bottom], args...) |>
    flex
hline(args...) = line(args...) |> height(0px)
vline(args...) = line(args...) |> width(0px)

## RoundRects

@api roundcorner => RoundedRect <: Tile begin
    arg(radius::Length)
    curry(tile::Tile)
    kwarg(corners::AbstractArray=Corner[])
end

render(t::RoundedRect) =
    render(t.tile) &
        (isempty(t.corners) ? # Apply padding to all sides if none specified
                [:style => ["borderRadius" => t.radius]] :
                [:style => ["borderRadius" * name(c) => t.radius for c=t.corners]])


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
