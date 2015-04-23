using Markdown

include("helpers/doc.jl")
include("helpers/page.jl")

typeexample(code, output=eval(parse(code))) =
  vbox(
     codeblock(code) |> fontcolor("#777"),
     output |> pad([left], 2em))

titles = vbox(
   intersperse(vskip(2em),
       map(n -> typeexample("title($n, \"Title $n\")"), 4:-1:1)))

headings = vbox(
   intersperse(vskip(2em),
       map(n -> typeexample("heading($n, \"Heading $n\")"), 1:4)))

function main(window)
    md"""
$(title(3, "Typography"))
$(vskip(1em))
Escher provides primitives that directly map to CSS font styling properties, as well as higher-level functions which form a standard typographic scale you can use to give your documents a consistent, pleasant look. By default, Escher uses the [*Source Sans Pro*](http://www.google.com/fonts/specimen/Source+Sans+Pro) (sans-serif) and [*Source Code Pro*](http://www.google.com/fonts/specimen/Source+Code+Pro) (monospaced) font families for great-looking and legible type.

# High-level Functions
$(vskip(1em))

$(h2("Titles"))

$(titles |> pad([left], 4em) |> pad([top, bottom], 1em))

$(h2("Headings"))

$(headings |> pad([left], 4em) |> pad([top, bottom], 1em))

# Low-level Functions

$(vskip(1em))

$(
   showdocs([fontsize, fontweight, fontcolor, fontstyle])
)

$(vskip(4em))

    """ |> centeredpage
end
