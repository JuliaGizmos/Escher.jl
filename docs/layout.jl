using Color
using Markdown

include("helpers/page.jl")
include("helpers/doc.jl")

intro = md"""
$(title(2, "Layout"))

$(vskip(1em))

Escher provides primitives like `hbox`, `vbox`, `hskip`, `vskip`, and `flex` for laying out tiles into grids. Complex layouts can be composed from smaller parts. For higher-order layouts such as tabs, pages, menus and collapsibles see [here](layout2).

$(vskip(1em))
# Functions
$(vskip(1em))

$(
    showdocs([hbox, width, height, flow])
)

"""

function main(window)
    centeredpage(intro)
end

