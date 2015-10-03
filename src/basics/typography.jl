using Colors
export plaintext,
       fontfamily,
       fontsize,
       fontweight,
       fontcolor,
       fontstyle,
       fonttype,
       fontcase,
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

abstract FontSize
# Note: I do not like these terms much. Could be irrational fear.
@terms FontSize begin
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

@api fontsize => (WithFontSize{T <: (@compat Union{FontSize, Length})} <: Tile) begin
    doc("Set the font size of text in one or more tiles")
    arg(size::T, doc="The font size")
    curry(tiles::TileList, doc="A tile or a list of tiles")
end
WithFontSize{T}(size::T, tiles) = WithFontSize{T}(size, tiles)

render{T <: Length}(t::WithFontSize{T}, state) =
    wrapmany(t.tiles, :span, state) & style(@d(:fontSize => t.size))
render{T <: FontSize}(t::WithFontSize{T}, state) =
    addclasses(wrapmany(t.tiles, :span, state), classes(t.size))

abstract FontWeight
# These terms add to the explosion as well.
@terms FontWeight begin
    bold => Bold
    bolder => Bolder
    lighter => Lighter
end
classes(::Bold) = "font-bold"
classes(::Bolder) = "font-bolder"
classes(::Lighter) = "font-lighter"

const allowed_font_weights = 100:100:900
@api fontweight => (WithFontWeight{T <: (@compat Union{Int, FontWeight})} <: Tile) begin
    doc("Set the font weight of text in one or more tiles.")
    arg(
        weight::T,
        doc="Font weight. Valid font weights are multiplies of 100 between 100 and 900."
    )
    curry(
        tiles::TileList,
        doc="A tile or a vector of tiles."
    )
end
WithFontWeight{T}(weight::T, tile) = WithFontWeight{T}(weight, tile)

render(t::WithFontWeight, state) = begin
    if !(t.weight in allowed_font_weights)
        error(string(t.weight, " is not an allowed font weight"))
    end
    wrapmany(t.tiles, :span, state) & style(@d(:fontWeight => t.weight))
end

render{T <: FontWeight}(t::WithFontWeight{T}, state) =
    addclasses(wrapmany(t.tiles, :span, state), classes(t.weight))

@api fontcolor => (FontColor <: Tile) begin
    doc("Set the font color.")
    arg(color::Color, doc="The color.")
    curry(tiles::TileList, doc="A tile or a vector of tiles.")
end

fontcolor(c::AbstractString) = fontcolor(parse(Colorant, c))
fontcolor(c::AbstractString, tiles) = fontcolor(parse(Colorant, c), tiles)

render(t::FontColor, state) =
    wrapmany(t.tiles, :span, state) & style(@d(:color => render_color(t.color)))

@api fontfamily => (FontFamily <: Tile) begin
    doc("Set the font family.")
    arg(family::AbstractString, doc="The font family")
    curry(tile::TileList, doc="A tile or a vector of tiles")
end
render(t::FontFamily, state) =
    wrapmany(t.tile, :span, state) & style(@d(:fontFamily => t.family))

abstract FontType
# TODO: Add serif and slab fonts
@terms FontType begin
    serif => Serif
    sansserif => SansSerif
    slabserif => SlabSerif
    monospace => Monospace
end
@api fonttype => (WithFontType <: Tile) begin
    doc("Set the font type.")
    arg(
        typ::FontType,
        doc=md"""The font type. Valid font types are `serif`, `sanserif`,
                 `slabserif` and `monospace`."""
    )
    curry(tiles::TileList, doc="A tile or a vector of tiles.")
end
classes(::Serif) = "font-serif"
classes(::SansSerif) = "font-sansserif"
classes(::SlabSerif) = "font-serif font-slab"
classes(::Monospace) = "font-monospace"

render(t::WithFontType, state) =
    addclasses(wrapmany(t.tiles, :span, state), classes(t.typ))

abstract FontStyle

@terms FontStyle begin
    normal => Normal
    slanted => Slanted
    italic => Italic
end
classes(::Normal) = "font-normal"
classes(::Slanted) = "font-slanted"
classes(::Italic) = "font-italic"

@api fontstyle => (WithFontStyle <: Tile) begin
    doc("Set the font style.")
    arg(
        style::FontStyle,
        doc=md"The font style. Valid font styles are `normal`, `slanted` and `italic`."
    )
    curry(tiles::TileList, doc="A tile or a vector of tiles.")
end
render(t::WithFontStyle, state) =
    addclasses(wrapmany(t.tiles, :span, state), classes(t.style))

abstract FontCase

# This exists purely for themability. (as opposed to using string case functions from Julia)
# e.g. .font-uppercase could sometimes use a different letter-spacing in a theme.
@terms FontCase begin
    ucase => Uppercase
    lcase => Lowercase
end
classes(::Uppercase) = "font-uppercase"
classes(::Lowercase) = "font-lowercase"

@api fontcase => (WithFontCase <: Tile) begin
    doc("Set the font case.")
    arg(case::FontCase, doc=md"The case. Valid cases are `ucase` and `lcase`")
    curry(tiles::TileList, doc="A tile or a vector of tiles.")
end

render(t::WithFontCase, state) =
    addclasses(wrapmany(t.tiles, :span, state), classes(t.case))

abstract TextAlignment

@terms TextAlignment begin
    raggedright => RaggedRight
    raggedleft => RaggedLeft
    justifytext => JustifyText
    centertext => CenterText
end

@api textalign => (AlignText{T <: TextAlignment} <: Tile) begin
    doc("Set the text alignment.")
    typedarg(
        alignment::T,
        doc=md"""The alignment. Valid alignments are `raggedright`, `raggedleft`,
                 `justifytext` and `centertext`."""
    )
    curry(tile::Tile, doc="A tile.")
end

render(t::AlignText{RaggedRight}, state) =
    render(t.tile, state) & style(@d(:textAlign => :left))
render(t::AlignText{RaggedLeft}, state) =
    render(t.tile, state) & style(@d(:textAlign => :right))
render(t::AlignText{JustifyText}, state) =
    render(t.tile, state) & style(@d(:textAlign => :justify))
render(t::AlignText{CenterText}, state) =
    render(t.tile, state) & style(@d(:textAlign => :center))

@api lineheight => (LineHeight <: Tile) begin
    doc("Set the height of lines of text.")
    arg(height::Length, doc="The height.")
    curry(tiles::TileList, doc="A tile or a vector of tiles.")
end
render(t::LineHeight, state) =
    wrapmany(t.tiles, :span, state) & style(@d(:lineHeight => t.height))

@api letterspacing => (LetterSpacing <: Tile) begin
    doc("Set the spacing between letters in text.")
    arg(space::Length, doc="The spacing.")
    curry(tiles::TileList, doc="A tile or a vector of tiles.")
end
render(t::LetterSpacing, state) =
    wrapmany(t.tiles, :span, state) & style(@d(:letterSpacing => t.space))

# Themable fonts

heading(n::Int, txt) = class("heading-$n", txt, forcewrap=true, wrap=:h1)
heading(n::Int) = t -> heading(n,t)

title(n::Int, txt) = class("title-$n", txt)

@apidoc title => (Class <: Tile) begin
    doc(md"Create a title.")
    arg(
        level::Int,
        doc="Title level. More is bigger. Valid values are integers 1 to 4."
    )
    curry(tile::TileList, doc="A tile or a vector of tiles.")
end

h1(txt) = heading(1, txt)
h2(txt) = heading(2, txt)
h3(txt) = heading(3, txt)
h4(txt) = heading(4, txt)

@apidoc heading => (Class <: Tile) begin
    doc(md"Create a heading. You can use `h1`, `h2`, `h3`, `h4` for brevity.")
    arg(level::Int, doc="Heading level.")
    curry(tile::TileList, doc="A tile or a vector of tiles.")
end

blockquote(txt) = class("blockquote", txt, forcewrap=true, wrap=:blockquote)
@apidoc blockquote => (Class <: Tile) begin
    doc("Create a quote block.")
    arg(tile::Tile, doc="The quote.")
end

caption(txt) = class("caption", txt, wrap=:span)
@apidoc caption => (Class <: Tile) begin
    doc("Create a caption.")
    arg(tile::Tile, doc="The caption.")
end

emph(txt) = class("emph", txt, forcewrap=true, wrap=:em)
@apidoc emph => (Class <: Tile) begin
    doc("Create a emphasized text.")
    arg(tile::Tile, doc="The text to be emphasized.")
end

@api code => (Code <: Tile) begin
    doc("Stylize text as code.")
    arg(code::Any, doc="The code.")
    kwarg(language::AbstractString="julia", doc="The language for syntax highlighting.")
end

## AbstractString will go inside a span, is this OK?
render(x::Code, state) = Elem(:code, render(x.code, state))

# colsize
