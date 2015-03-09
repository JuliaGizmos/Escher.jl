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

convert(::Type{Tile}, md::Markdown.MD) = totile(md)

totile(x) = convert(Tile, x)
totile(xs::AbstractArray) = group(map(totile, xs))
totile(md::Markdown.MD) = totile(md.content)
totile{n}(md::Markdown.Header{n}) = headline(n, totile(md.text))
totile(md::Markdown.Code) = code(md.language, totile(md.code))
totile(md::Markdown.BlockQuote) = blockquote(totile(md.content))
totile(md::Markdown.List) = map(totile, md.items)
totile(md::Markdown.Paragraph) = paragraph(totile(md.content))
totile(md::Markdown.Italic) = font(italic, totile(md.text))
totile(md::Markdown.Bold) = font(bold, totile(md.text))
totile(md::Markdown.Image) = font(bold, totile(md.text))
