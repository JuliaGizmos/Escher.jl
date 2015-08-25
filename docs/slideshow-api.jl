using Colors

include("helpers/page.jl")
include("helpers/doc.jl")

intro = md"""
$(title(2, "SlideShow"))
$(vskip(1em))

# Functions
$(vskip(1em))

$(
   showdocs([slideshow, slide])
)

$(vskip(4em))

"""

function main(window)
    docpage(intro)
end

