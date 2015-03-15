import Markdown

# Paragraph
# Header{level}
# Code(language, code)
# BlockQuote
# List(items, ordered)
# Italic
# Bold
# Image(url, alt)
# Link(text, url)
# LaTeX

totile(x) = x
convert(::Type{Tile}, md::Markdown.MD) = totile(md)
convert(::Type{Union(Tile, String)}, md::Markdown.MD) = totile(md)

totile(xs::AbstractArray) = inline(map(totile, xs))
totile(md::Markdown.MD) = totile(md.content)
totile{n}(md::Markdown.Header{n}) = heading(n, totile(md.text))
totile(md::Markdown.Code) = code(md.language, totile(md.code))
totile(md::Markdown.BlockQuote) = blockquote(totile(md.content))
totile(md::Markdown.List) = map(totile, md.items)
totile(md::Markdown.Paragraph) = paragraph(totile(md.content))
totile(md::Markdown.Italic) = emph(totile(md.text))
totile(md::Markdown.Bold) = font(bold, totile(md.text))
