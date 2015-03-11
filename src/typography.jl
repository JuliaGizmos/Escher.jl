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
       fontweight,
       heading,
       h1, h2, h3, h4,
       paragraph,
       emph,
       codeblock,
       blockquote,
       caption,
       title,
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

function fontweight(w::Integer)
    if !(w in allowed_font_weights)
        error(string(w, " is not an allowed font weight"))
    end
    NumericFontWeight{w}()
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

immutable TextClass{tag, class} <: Tile
    tile::Union(Tile, String)
end

heading(n::Int, txt) = TextClass{symbol("h$n"), symbol("heading-$n")}(txt)

h1(txt) = heading(1, txt)
h2(txt) = heading(2, txt)
h3(txt) = heading(3, txt)
h4(txt) = heading(4, txt)

title(n::Int, txt) = TextClass{symbol("h$n"), symbol("title-$n")}(txt)
paragraph(txt) = TextClass{:p, :paragraph}(txt)
caption(txt) = TextClass{:p, :caption}(txt)
emph(txt) = TextClass{:em, :emphasis}(txt)
codeblock(txt) = TextClass{:pre, :codeblock}(txt)

immutable BlockQuote <: Tile
    tile::Tile
end
blockquote(txt) = BlockQuote(txt)

# colsize
