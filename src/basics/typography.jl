using Color

export plaintext,
       fontfamily,
       fontsize,
       fontweight,
       serif,
       sansserif,
       slabserif,
       monospace,
       normal,
       slanted,
       italic,
       ucase,
       lcase,
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
       lineheight,
       letterspacing,
       heading,
       h1, h2, h3, h4,
       paragraph,
       emph,
       codeblock,
       code,
       blockquote,
       caption,
       title

plaintext(x) = Leaf(Elem(:div, string(x)))

abstract FontSizeName
# Note: I do not like these terms much. Could be irrational fear.
@terms FontSizeName begin
    xxsmall => XXSmall
    xsmall => XSmall
    small => Small
    medium => Medium
    large => Large
    xlarge => XLarge
    xxlarge => XXLarge
end
classes(::XXSmall) = "font-xx-small"
classes(::XSmall) = "font-x-small"
classes(::Small) = "font-small"
classes(::Medium) = "font-medium"
classes(::Large) = "font-large"
classes(::XLarge) = "font-x-large"
classes(::XXLarge) = "font-xx-large"

@api fontsize => FontSize{T <: Union(FontSizeName, Length)} <: Tile begin
    arg(size::T)
    curry(tile::TileList)
end
render{T <: Length}(t::FontSize{T}) =
    wrapmany(t.tile, :span) & [:style => [:fontSize => t.size]]
render{T <: FontSizeName}(t::FontSize{T}) =
    addclasses(wrapmany(t.tile, :span), classes(t.size))

abstract RelativeFontWeight
# These terms add to the explosion as well.
@terms RelativeFontWeight begin
    bold => Bold
    bolder => Bolder
    lighter => Lighter
end
classes(::Bold) = "font-bold"
classes(::Bolder) = "font-bolder"
classes(::Lighter) = "font-lighter"

const allowed_font_weights = 100:100:900
@api fontweight => FontWeight{T <: Union(Int, RelativeFontWeight)} <: Tile begin
    arg(weight::T)
    curry(tile::TileList)
end
FontWeight{T}(weight::T, tile) = FontWeight{T}(weight, tile)

function render(t::FontWeight)
    if !(w in allowed_font_weights)
        error(string(w, " is not an allowed font weight"))
    end
    wrapmany(t.tile, :span) & [:style => [:fontWeight => t.weight]]
end

render{T <: RelativeFontWeight}(t::FontWeight{T}) =
    addclasses(wrapmany(t.tile, :span), classes(t.weight))

@api fontcolor => FontColor <: Tile begin
    arg(color::ColorValue)
    curry(tile::TileList)
end
render(t::FontColor) =
    wrapmany(t.tile, :span) & [:style => [:color => t.color]]

@api fontfamily => FontFamily <: Tile begin
    arg(family::String)
    curry(tile::TileList)
end
render(t::FontFamily) =
    wrapmany(t.tile, :span) & [:style => [:fontFamily => t.family]]

abstract FontType
# TODO: Add serif and slab fonts
@terms FontType begin
    serif => Serif
    sansserif => SansSerif
    slabserif => SlabSerif
    monospace => Monospace
end
@api fonttype => WithFontType begin
    arg(typ::FontType)
    curry(tile::Tile)
end
classes(::Serif) = "font-serif"
classes(::SansSerif) = "font-sansserif"
classes(::SlabSerif) = "font-serif font-slab"
classes(::Monospace) = "font-monospace"

render(t::WithFontType) =
    addclasses(wrapmany(t.tile, :span), classes(t.typ))

abstract FontStyle

@terms FontStyle begin
    normal => Normal
    slanted => Slanted
    italic => Italic
end
classes(::Normal) = "font-normal"
classes(::Slanted) = "font-slanted"
classes(::Italic) = "font-italic"

@api fontstyle => WithFontStyle begin
    arg(style::FontStyle)
    curry(tile::Tile)
end
render(t::WithFontStyle) =
    addclasses(wrapmany(t.tile, :span), classes(t.style))

abstract FontCase

# This exists purely for themability. (as opposed to using string case functions from Julia)
# e.g. .font-uppercase could sometimes use a different letter-spacing in a theme.
@terms FontCase begin
    ucase => Uppercase
    lcase => Lowercase
end
classes(::Uppercase) = "font-uppercase"
classes(::Lowercase) = "font-lowercase"

@api fontcase => WithFontCase begin
    arg(case::FontCase)
    curry(tile::Tile)
end

render(t::WithFontCase) =
    addclasses(wrapmany(t.tile, :span), classes(t))

abstract TextAlignment

@terms TextAlignment begin
    raggedright => RaggedRight
    raggedleft => RaggedLeft
    justifytext => JustifyText
    centertext => CenterText
end

@api textalign => AlignText{T <: TextAlignment} begin
    typedarg(alignment::T)
    curry(tile::Tile)
end

render(t::AlignText{RaggedRight}) =
    render(t.tile) & [:style => [:textAlign => :left]]
render(t::AlignText{RaggedLeft}) =
    render(t.tile) & [:style => [:textAlign => :right]]
render(t::AlignText{JustifyText}) =
    render(t.tile) & [:style => [:textAlign => :justify]]
render(t::AlignText{CenterText}) =
    render(t.tile) & [:style => [:textAlign => :center]]

@api LineHeight => LineHeight begin
    arg(height::Length)
    curry(tiles::TileList)
end
render(t::LineHeight) =
    wrapmany(t.tile, :span) & [:style => [:lineHeight => t.size]]

@api lineheight => LineHeight begin
    arg(height::Length)
    curry(tiles::TileList)
end
render(t::LineHeight) =
    wrapmany(t.tile, :span) & [:style => [:lineHeight => t.height]]

@api letterspacing => LetterSpacing begin
    arg(space::Length)
    curry(tiles::TileList)
end
render(t::LetterSpacing) =
    wrapmany(t.tile, :span) & [:style => [:letterSpacing => t.space]]

# Themable fonts

heading(n::Int, txt) = class("heading-$n", txt, forcewrap=true, wrap=:h1)
title(n::Int, txt) = class("title-$n", txt)

h1(txt) = heading(1, txt)
h2(txt) = heading(2, txt)
h3(txt) = heading(3, txt)
h4(txt) = heading(4, txt)

paragraph(txt) = class("paragraph", txt, forcewrap=true, wrap=:p)
blockquote(txt) = class("blockquote", txt, forcewrap=true, wrap=:blockquote)
caption(txt) = class("caption", txt, wrap=:span)
emph(txt) = class("emph", txt, forcewrap=true, wrap=:em)

@api code => Code <: Tile begin
    arg(code::Any)
    kwarg(language::String="julia")
end

## String will go inside a span, is this OK?
render(x::Code) = Elem(:code, render(x.code))

@api codeblock => CodeBlock <: Tile begin
    arg(code::Any)
    kwarg(language::String="julia")
end

render(x::CodeBlock) = Elem(:pre, render(x.code))

# colsize
