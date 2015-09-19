using Colors


include("helpers/page.jl")
include("helpers/doc.jl")

intro = md"""
$(title(2, "Behavior"))
$(vskip(1em))

# Functions
$(vskip(1em))

$(
   showdocs([hasstate, keypress, clickable, selectable, send, recv, wire])
)

$(vskip(4em))

"""

function main(window)
    docpage(intro)
end

