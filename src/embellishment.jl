using Color

export noborder,
       dotted,
       dashed,
       solid,
       strokewidth,
       border,
       bordercolor,
       roundcorner,
       shadow,
       fillcolor

## Borders

abstract BorderProperty

abstract StrokeStyle <: BorderProperty
@terms StrokeStyle begin
    noborder => NoStroke
    dotted => Dotted
    dashed => Dashed
    solid => Solid
end

immutable StrokeWidth <: BorderProperty
    thickness::Length
end
strokewidth(x) = StrokeWidth(x)

immutable BorderColor <: BorderProperty
    color::ColorValue
end
bordercolor(c) = BorderColor(c)

immutable WithBorder{P <: BorderProperty} <: Tile
    sides::AbstractArray{Side}
    prop::P
    tile::Tile
end

border(sides::AbstractArray, p::Length, x) =
    WithBorder(sides, strokewidth(p), convert(Tile, x))

border(sides::AbstractArray, p::BorderProperty, x) =
    WithBorder(sides, p, convert(Tile, x))

border(sides::AbstractArray, p::ColorValue, x) =
    WithBorder(sides, bordercolor(p), convert(Tile, x))

border(p::Union(BorderProperty, ColorValue, Length), x) =
    border(Side[], p, convert(Tile, x))

border(t::Union(Tile, String), props::BorderProperty...) =
    foldr(border, t, props)

border(sides::AbstractArray, t::Union(Tile, String), props::BorderProperty...) =
    foldr((x, y) -> border(sides, x, y), t, props)

border(sides::AbstractArray, props::BorderProperty...) =
    t -> border(sides, t, props...)

border(props::BorderProperty...) =
    t -> border(t, props...)

## RoundRects

immutable RoundedRect <: Tile
    corners::AbstractArray{Corner}
    radius::Length
    tile::Tile
end

roundcorner(radius, tile; corners=Corner[]) =
    RoundedRect(corners, radius, tile)
roundcorner(radius::Length; corners=Corner[]) =
    t -> roundcorner(radius, t; corners=Corner[]) =

## Box shadow

immutable Shadow <: Tile
    inset::Bool
    offset::(Length, Length)
    blur_radius::Length
    spread_radius::Length
    color::ColorValue
    tile::Tile
end

shadow(tile;
    inset=false,
    offset=(0px, 0px),
    blur_radius=5px,
    spread_radius=5px,
    color=color("black")) =
    Shadow(inset, offset, blur_radius, spread_radius, color, tile)

## Fill color

immutable FillColor <: Tile
    color::ColorValue
    tile::Tile
end

fillcolor(color::ColorValue, t) =
    FillColor(color, t)

fillcolor(color::ColorValue) =
    t -> fillcolor(color, t)

