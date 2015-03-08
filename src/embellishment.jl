using Color

export noborder,
       dotted,
       dashed,
       solid,
       border,
       roundcorner,
       hline,
       vline,
       shadow,
       fillcolor

## Borders

abstract StrokeStyle

@terms StrokeStyle begin
    noborder => NoStroke
    dotted => Dotted
    dashed => Dashed
    solid => Solid
end

immutable Bordered <: Tile
    sides::AbstractArray{Direction}
    stroke::StrokeStyle
    thickness::Length
    color::ColorValue
    tile::Tile
end

border(tile;
    color=color("lightgray"),
    thickness=1px,
    sides=Direction[],
    stroke=solid) =
    Bordered(sides, stroke, thickness, color, tile)

## RoundRects

immutable RoundedCorner <: Tile
    corners::AbstractArray{Corner}
    radius::Length
    tile::Tile
end

roundcorner(tile;
    corners=Corner[],
    radius=Length) =
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

## Library

hline(len=100cent; kwargs...) = border(size(len, 0px, empty); kwargs...)
vline(len=100cent; kwargs...) = border(size(0px, len, empty); kwargs...)

