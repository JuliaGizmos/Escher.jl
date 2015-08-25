using Colors

include("helpers/page.jl")
include("helpers/doc.jl")

intro = md"""
$(title(2, "Layout"))

$(vskip(1em))

Escher provides primitives like `hbox`, `vbox`, `hskip`, `vskip`, and `flex` for laying out tiles into grids. Complex layouts can be composed from smaller parts. For higher-order layouts such as tabs, pages, menus and collapsibles see [here](layout2-api.html).

$(vskip(1em))
# Functions
$(vskip(1em))

$(
    showdocs([width, height, size, container, minwidth, minheight, maxwidth,
              maxheight, clip, pad, flow, hbox, vbox, shrink, grow, flex, 
              packitems, packacross, packlines])
)
"""

function main(window)
    docpage(intro)
end

