if VERSION < v"0.4.0-dev"
    import Markdown
else
    const Markdown = Base.Markdown
end


convert(::Type{Tile}, md::Markdown.MD) = blocktile(md)

blocktile(x) = convert(Tile, x)
inlinetile(x) = convert(Tile, x)
blocktile(x::Tile) = x
inlinetile(x::Tile) = x

blocktile(md::Markdown.MD) = vbox(map(blocktile, md.content))
inlinetile(x::String) = x

blocktile{n}(md::Markdown.Header{n}) =
    class("md-heading", heading(n, map(inlinetile, md.text)))

inlinetile(md::Markdown.Code) = code(md.code, language=md.language)
blocktile(md::Markdown.Code)  =
    class("md-codeblock", codemirror(md.code, language=md.language, linenumbers=false, readonly=true))

blocktile(md::Markdown.BlockQuote) =
    class("md-blockquote", blockquote(map(blocktile, md.content)))
blocktile(md::Markdown.List) =
    class("md-list", list(map(item -> map(inlinetile, item), md.items), ordered=md.ordered))
blocktile(md::Markdown.Paragraph) =
    class("md-paragraph", map(inlinetile, md.content))

inlinetile(md::Markdown.Italic) = emph(map(inlinetile, md.text))
inlinetile(md::Markdown.Bold) = fontweight(bold, map(inlinetile, md.text))
inlinetile(md::Markdown.Link) = link(md.url, map(inlinetile, md.text))

inlinetile(md::Markdown.Image) = img(md.url, alt=md.alt)
blocktile(md::Markdown.Image) = class("md-img", img(md.url, alt=md.alt))

inlinetile(md::Markdown.LaTeX) = tex(md.formula, block=false)
blocktile(md::Markdown.LaTeX) = class("md-tex", latex(md.formula, block=true))
