using Color

import Base: fill

export fill,
       color

immutable Styled{attr}
    value
    tile
end

fill(c::ColorValue, tile) =
    Style{:fillColor}(c, tile)

textcolor(c::Union(ColorValue, AlphaColorValue), tile) =
    Style{:color}(c, tile)

border(tile::Tile, c::Union(ColorValue, AlphaColorValue)) =
    Style{:borderColor}(c)

# Styling:

# FillColor
# Opacity
# FgColor
# FontFamily
# FontSize
# FontStyle
# FontWeight

# BorderStyle
# BorderColor
# BorderWeight

# BoxRadius
