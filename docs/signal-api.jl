using Color

include("helpers/page.jl")
include("helpers/doc.jl")

intro = md"""
$(title(2, "Signal"))
$(vskip(1em))

# Functions
$(vskip(1em))

$(
   showdocs([stoppropagation, addinterpreter, constant, pairwith, sampler,
             plugsampler, watch!, trigger!, subscribe])
)

$(vskip(4em))

"""

function main(window)
    docpage(intro)
end

