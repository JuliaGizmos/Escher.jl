using Colors

include("helpers/page.jl")
include("helpers/doc.jl")

intro = md"""
$(title(2, "Content"))
$(vskip(1em))

# Functions
$(vskip(1em))

$(
    showdocs([Escher.list, image, link, abbr])
)
"""

function main(window)
    docpage(intro)
end

