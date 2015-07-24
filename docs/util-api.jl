using Color
using Markdown

include("helpers/page.jl")
include("helpers/doc.jl")

intro = md"""
$(title(2, "Util"))
$(vskip(1em))

# Functions
$(vskip(1em))

$(
   showdocs([Escher.class])
)

$(vskip(4em))

"""

function main(window)
    docpage(intro)
end

