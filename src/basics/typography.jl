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
       code,
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

@api font => WithFont{P <: FontProperty} <: Tile begin
    typedarg(prop::P)
    curry(tile::Tile)
end

font(t::Union(Tile, String), args::FontProperty...) =
    foldr(font, t, props)

font(props::FontProperty...) =
    t -> foldr(font, t, props)

render(t::WithFont) =
    addclasses(render(t.tile), classes(t))

abstract NamedFontProperty <: FontProperty
abstract AbsFontProperty <: FontProperty

type FontFamily <: AbsFontProperty
    family::String
end
fontfamily(f) = FontFamily(f)

render(t::WithFont{FontFamily}) =
    render(t.tile) & [:style => [:fontFamily => t.prop.family]]


abstract FontType <: NamedFontProperty

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

abstract FontStyle <: NamedFontProperty

@terms FontStyle begin
    normal => Normal
    slanted => Slanted
    italic => Italic
end
classes(::WithFont{Normal}) = "font-normal"
classes(::WithFont{Slanted}) = "font-slanted"
classes(::WithFont{Italic}) = "font-italic"

abstract FontCase <: NamedFontProperty

@terms FontCase begin
    ucase => Uppercase
    lcase => Lowercase
end
classes(::WithFont{Uppercase}) = "font-uppercase"
classes(::WithFont{Lowercase}) = "font-lowercase"

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
classes(::WithFont{XXSmall}) = "font-xx-small"
classes(::WithFont{XSmall}) = "font-x-small"
classes(::WithFont{Small}) = "font-small"
classes(::WithFont{Medium}) = "font-medium"
classes(::WithFont{Large}) = "font-large"
classes(::WithFont{XLarge}) = "font-x-large"
classes(::WithFont{XXLarge}) = "font-xx-large"


immutable AbsFontSize <: AbsFontProperty
    size::Length
end
fontsize(size::Length) = AbsFontSize(size)

render(t::WithFont{AbsFontSize}) =
    render(t.tile) & [:style => [:fontSize => t.prop.size]]


abstract FontWeight <: NamedFontProperty

@terms FontWeight begin
    bold => Bold
    bolder => Bolder
    lighter => Lighter
end
classes(::WithFont{Bold}) = "font-bold"
classes(::WithFont{Bolder}) = "font-bolder"
classes(::WithFont{Lighter}) = "font-lighter"

immutable NumericFontWeight{n} <: AbsFontProperty
end

render{n}(t::WithFont{NumericFontWeight{n}}) =
    render(t.tile) & [:style => [:fontWeight => n]]

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

immutable TextClass{tag, class} <: Tile
    tile::Union(Tile, String)
end
render{tag, class}(p::TextClass{tag, class}) =
    addclasses(Elem(tag, render(p.tile)), string(class))


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

@api code => Code <: Tile begin
    arg(language::String="julia")
    arg(code::Any)
end

render(x::Code) = Elem(:code, x.code)

@api blockquote => BlockQuote <: Tile begin
    arg(tile::Tile)
end

render(b::BlockQuote) =
    Elem("blockquote", render(b.tile))

# colsize
