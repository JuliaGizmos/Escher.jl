export plaintext,
       nowrap,
       font,
       fontfamily,
       serif,
       sansserif,
       slabserif,
       monospace,
       normal,
       slanted,
       italic,
       uppercase,
       lowercase,
       tiny,
       small,
       medium,
       big,
       huge,
       thin,
       extralight,
       light,
       book,
       mediumweight,
       semibold,
       bold,
       heavy,
       fat,
       textalign,
       raggedright,
       raggedleft,
       justify,
       centertext,
       fontwieght

plaintext(x) = div(x)

# nowrap

immutable NoTextWrap <: Tile
    tile::Tile
end

nowrap(tile) = NoTextWrap(tile)

# Font properties

abstract FontProperty

immutable WithFont{P <: FontProperty} <: Tile
    prop::P
    tile::Tile
end

font(w::FontProperty, x) =
    WithFont(w, convert(Tile, x))

font(t::Union(Tile, String), args::FontProperty...) =
    foldr(font, t, props)

font(props::FontProperty...) =
    t -> foldr(font, t, props)

abstract NamedFontProperty <: FontProperty
abstract AbsFontProperty <: FontProperty

type FontFamily <: AbsFontProperty
    family::String
end
fontfamily(f) = FontFamily(f)

abstract FontType <: NamedFontProperty

@terms FontType begin
    serif => Serif
    sansserif => SansSerif
    slabserif => SlabSerif
    monospace => Monospace
end

abstract FontStyle <: NamedFontProperty

@terms FontStyle begin
    normal => Normal
    slanted => Slanted
    italic => Italic
end

abstract FontCase <: NamedFontProperty

@terms FontCase begin
    uppercase => Uppercase
    lowercase => Lowercase
end

abstract FontSize <: NamedFontProperty

@terms FontSize begin
    tiny => TinyFont
    small => SmallFont
    medium => MediumFont
    big => BigFont
    huge => HugeFont
end

abstract FontWeight <: NamedFontProperty

@terms FontWeight begin
    thin => Thin
    extralight => ExtraLight
    light => Light
    book => BookWeight
    mediumweight => MediumWeight
    semibold => SemiBold
    bold => Bold
    heavy => Heavy
    fat => FatWeight
end

immutable NumericFontWeight{n} <: AbsFontProperty
end

const allowed_font_weights = 100:100:900

function fontweight(w::Integer, x)
    if !(x in allowed_font_weights)
        error(string(x, " is not an allowed font weight"))
    end
    NumericFontWeight{n}(x)
end

abstract TextAlignment

@terms TextAlignment begin
    raggedright => RaggedRight
    raggedleft => RaggedLeft
    justifytext => JustifyText
    centertext => CenterText
end

immutable AlignText{T <: TextAlignment}
    tile::Tile
end

textalign{T <: TextAlignment}(a::T, t) =
    AlignText{T}(t)
textalign{T <: TextAlignment}(a::T) =
    t -> textalign(a, t)

# Headers
immutable Headline{n} <: Tile
    tile::Tile
end

headline(n, tile) = Headline{n}(tile)
headline(n) = t -> Headline{n}(t)

immutable Paragraph
    tile::Tile
end
paragraph(x) = Paragraph(t)

# colsize
