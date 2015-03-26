import Markdown

convert(::Type{Tile}, md::Markdown.MD) = blocktile(md)

blocktile(md::Markdown.MD) = vbox(map(blocktile, md.content))
inlinetile(x::String) = x

blocktile{n}(md::Markdown.Header{n}) = heading(n, map(inlinetile, md.text))

inlinetile(md::Markdown.Code) = code(md.code, language=md.language)
blocktile(md::Markdown.Code)  = codeblock(md.code, language=md.language)

blocktile(md::Markdown.BlockQuote) = blockquote(map(blocktile, md.content))
blocktile(md::Markdown.List) = list(map(item -> map(inlinetile, item), md.items), ordered=md.ordered)
blocktile(md::Markdown.Paragraph) = paragraph(map(inlinetile, md.content))

inlinetile(md::Markdown.Italic) = emph(map(inlinetile, md.text))
inlinetile(md::Markdown.Bold) = font(bold, map(inlinetile, md.text))
inlinetile(md::Markdown.Link) = link(md.url, map(inlinetile, md.text))

inlinetile(md::Markdown.Image) = img(md.url, alt=md.alt)
blocktile(md::Markdown.Image) = img(md.url, alt=md.alt)

inlinetile(md::Markdown.LaTeX) = latex(md.formula, block=false)
blocktile(md::Markdown.LaTeX) = latex(md.formula, block=true)
