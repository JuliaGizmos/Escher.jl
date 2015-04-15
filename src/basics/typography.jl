export plaintext,
       nowrap,
       font,
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
       heading,
       h1, h2, h3, h4,
       paragraph,
       emph,
       codeblock,
       code,
       blockquote,
       caption,
       title,
       menufont

plaintext(x) = div(x)

# nowrap

@api nowrap => NoTextWrap <: Tile begin
    arg(tile::Tile)
end

# Font properties

abstract FontProperty

@api font => WithFont{T <: FontProperty} <: Tile begin
    typedarg(prop::T)
    curry(tile::TileList)
end
WithFont{T}(prop::T, t) = WithFont{T}(prop, t)

font(t::Union(Tile, String), args::FontProperty...) =
    foldr(font, t, props)

font(props::FontProperty...) =
    t -> foldr(font, t, props)

render(t::WithFont) =
    addclasses(wrapmany(t.tile, :span), classes(t))

type FontFamily <: FontProperty
    family::String
end
fontfamily(f) = FontFamily(f)

render(t::WithFont{FontFamily}) =
    wrapmany(t.tile, :span) & [:style => [:fontFamily => t.prop.family]]


abstract FontType <: FontProperty

@terms FontType begin
    serif => Serif
    sansserif => SansSerif
    slabserif => SlabSerif
    monospace => Monospace
end
classes(::WithFont{Serif}) = "font-serif"
classes(::WithFont{SansSerif}) = "font-sansserif"
classes(::WithFont{SlabSerif}) = "font-serif font-slab"
classes(::WithFont{Monospace}) = "font-monospace"

abstract FontStyle <: FontProperty

@terms FontStyle begin
    normal => Normal
    slanted => Slanted
    italic => Italic
end
classes(::WithFont{Normal}) = "font-normal"
classes(::WithFont{Slanted}) = "font-slanted"
classes(::WithFont{Italic}) = "font-italic"

abstract FontCase <: FontProperty

@terms FontCase begin
    ucase => Uppercase
    lcase => Lowercase
end
classes(::WithFont{Uppercase}) = "font-uppercase"
classes(::WithFont{Lowercase}) = "font-lowercase"

abstract FontSize <: FontProperty
@terms FontSize begin
    xxsmall => XXSmall
    xsmall => XSmall
    small => Small
    medium => Medium
    large => Large
    xlarge => XLarge
    xxlarge => XXLarge
end
classes(::WithFont{XXSmall}) = "font-xx-small"
classes(::WithFont{XSmall}) = "font-x-small"
classes(::WithFont{Small}) = "font-small"
classes(::WithFont{Medium}) = "font-medium"
classes(::WithFont{Large}) = "font-large"
classes(::WithFont{XLarge}) = "font-x-large"
classes(::WithFont{XXLarge}) = "font-xx-large"


immutable AbsFontSize <: FontProperty
    size::Length
end
fontsize(size::Length) = AbsFontSize(size)

render(t::WithFont{AbsFontSize}) =
    wrapmany(t.tile, :span) & [:style => [:fontSize => t.prop.size]]


abstract FontWeight <: FontProperty

@terms FontWeight begin
    bold => Bold
    bolder => Bolder
    lighter => Lighter
end
classes(::WithFont{Bold}) = "font-bold"
classes(::WithFont{Bolder}) = "font-bolder"
classes(::WithFont{Lighter}) = "font-lighter"

immutable NumericFontWeight{n} <: FontProperty
end

render{n}(t::WithFont{NumericFontWeight{n}}) =
    wrapmany(t.tile, :span) & [:style => [:fontWeight => n]]

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

render(x::Code) = Elem(:code, x.code)

@api codeblock => CodeBlock <: Tile begin
    arg(code::Any)
    kwarg(language::String="julia")
end

render(x::CodeBlock) = Elem(:pre, x.code)

# colsize
