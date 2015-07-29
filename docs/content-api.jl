using Color
using Markdown

include("helpers/page.jl")
include("helpers/doc.jl")

intro = md"""
$(title(2, "Content"))
$(vskip(1em))

# Functions
$(vskip(1em))

$(
    showdocs([list, image, link, abbr])
)
"""

function main(window)
    docpage(intro)
end

