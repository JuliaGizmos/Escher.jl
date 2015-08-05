using Markdown

const content = 
    vbox(
        title(1, "Content"),
        "Rendering everyday Julia objects",
        "Markdown",
        "Font",
        "TeX/mathematics",
        "Images",
        "Plots",
        "Vector graphics",
    )

const layout =
    vbox(
        title(1, "Layout"),
        "Width and Height",
        md"`hbox` and `vbox`",
        "Padding",
        "Absolute positioning",
        "Packing space",
        "Fill color",
        "Borders and Colors",
    )

const widgets_toc =
    vbox(
        title(1, "Widgets"),
        "Basic input widgets",
        "Code mirror",
        "Camera widget",
    )

const interaction =
    vbox(
        title(1, "Interaction"),
        "Signals",
        "A counter",
        "A series of counters",
        "Animations",
        "Combining signals",
    )

function main(window)
    vbox(
        title(2, "Examples"),
        hbox(content, hskip(2em), layout),
        hbox(interaction, hskip(2em), widgets_toc),
    ) |> Escher.pad(2em)
    
end
