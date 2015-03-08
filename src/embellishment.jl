using Color

export noborder,
       dotted,
       dashed,
       solid,
       border,
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

immutable StrokeThickness <: BorderProperty
    thickness::Length
end

immutable BorderColor <: BorderProperty
    color::AlphaColorValue
end

immutable WithBorder{P <: BorderProperty} <: Tile
    sides::AbstractArray{Direction}
    stroke::P
    tile::Tile
end

border(sides::AbstractArray, p::BorderProperty, x) =
    WithBorder(sides, p, convert(Tile, x))
border(t::Union(Tile, String), args::BorderProperty...) =
    foldr(font, t, props)
border(props::BorderProperty...) =
    t -> border(t, args)

## RoundRects

immutable RoundedRect <: Tile
    corners::AbstractArray{Corner}
    radius::Length
    tile::Tile
end

roundcorner(radius, tile; corners=Corner[]) =
    RoundedCorner(corners, radius, tile)

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

