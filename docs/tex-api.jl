using Colors

include("helpers/page.jl")
include("helpers/doc.jl")

intro = md"""
$(title(2, "TeX"))
$(vskip(1em))

# Functions
$(vskip(1em))

$(
   showdocs([tex])
)

$(vskip(4em))

"""

function main(window)
    docpage(intro)
end

