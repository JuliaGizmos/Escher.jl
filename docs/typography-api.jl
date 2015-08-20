using Color

include("helpers/page.jl")
include("helpers/doc.jl")

intro = md"""
$(title(2, "Typography"))
$(vskip(1em))

# Functions
$(vskip(1em))

$(
   showdocs([fontsize, fontweight, fontcolor, fontstyle, fontfamily, fonttype,
             fontcase, textalign, lineheight, letterspacing, title, heading, 
             blockquote, caption, emph, code])
)

$(vskip(4em))

"""

function main(window)
    docpage(intro)
end

