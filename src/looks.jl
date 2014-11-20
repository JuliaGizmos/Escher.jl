using Color

fill(elem::Elem, c::Union(ColorValue, AlphaColorValue)) =
    style(elem, :backgroundColor, string("#", hex(c)))

color(elem::Elem, c::Union(ColorValue, AlphaColorValue)) =
    style(elem, :color, string("#", hex(c)))

fill(elem::Elem, c::String) =
    style(elem, :backgroundColor, string("#", hex(c)))

color(elem::Elem, c::String) =
    style(elem, :color, string("#", hex(c)))
