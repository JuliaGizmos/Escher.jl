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
       xxsmall,
       xsmall,
       small,
       medium,
       large,
       xlarge,
       xxlarge,
       bold,
       bolder,
       lighter,
       textalign,
       raggedright,
       raggedleft,
       justify,
       centertext,
       fontwieght,
       headline,
       title,
       subhead,
       paragraph,
       caption,
       displayfont,
       menufont

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
    xxsmall => XXSmall
    xsmall => XSmall
    small => Small
    medium => Medium
    large => Large
    xlarge => XLarge
    xxlarge => XXLarge
end

immutable AbsFontSize <: AbsFontProperty
    size::Length
end
fontsize(size::Length) = AbsFontSize(size)

abstract FontWeight <: NamedFontProperty

@terms FontWeight begin
    bold => Bold
    bolder => Bolder
    lighter => Lighter
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

# Themable fonts
# With help from the material design spec
# http://www.google.com/design/spec/style/typography.html#typography-standard-styles

immutable FontClass{class} <: Tile
    tile::Tile
end

title(t) = FontClass{:title}(t)
paragraph(t) = FontClass{symbol("body-1")}(t)
headline(t) = FontClass{:headline}(t)
headline(n, t) = FontClass{symbol("headline-" * string(n))}(t)
subhead(t) = FontClass{:subhead}(t)
caption(t) = FontClass{:caption}(t)
menu(t) = FontClass{:menu}(t)

displayfont(n, tile) =
    FontClass{symbol(string("display", '-', n))}(tile)
displayfont(n::Int) =
    t -> displayfont(n, t)

immutable BlockQuote <: Tile
    tile::Tile
end
blockquote(txt) = BlockQuote(txt)

# colsize
