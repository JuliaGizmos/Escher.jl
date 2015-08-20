using Color

include("helpers/page.jl")
include("helpers/doc.jl")

intro = md"""
$(title(2, "Embellishment"))
$(vskip(1em))

# Functions
$(vskip(1em))

$(
   showdocs([ bordercolor, borderwidth, borderstyle, border, hline, vline, 
              roundcorner, shadow, fillcolor     
            ])
)

$(vskip(4em))

"""

function main(window)
    docpage(intro)
end

