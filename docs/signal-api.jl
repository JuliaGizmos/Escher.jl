using Colors

include("helpers/page.jl")
include("helpers/doc.jl")

intro = md"""
$(title(2, "Signal"))
$(vskip(1em))

# Functions
$(vskip(1em))

$(
   showdocs([subscribe, intent, sampler,
             watch!, trigger!, bubble])
)

$(vskip(4em))

"""

function main(window)
    docpage(intro)
end

