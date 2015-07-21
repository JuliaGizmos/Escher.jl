using Color
using Markdown

include("helpers/page.jl")
include("helpers/doc.jl")

intro = md"""
$(title(2, "Widgets"))
$(vskip(1em))

# Functions
$(vskip(1em))

$(
    showdocs([button, slider, checkbox, togglebutton,
    radio, radiogroup, textinput, progress, paper, datepicker, codemirror])
)
"""

function main(window)
    docpage(intro)
end

