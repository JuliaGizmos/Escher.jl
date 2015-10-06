using Colors
include("helpers/listing.jl")

various_str = """vbox(
  tex("(a+b)^2=a^2+b^2+2ab"),
  blockquote(md" ```map``` is a function that that applies a given **function** to each element of a **list**, returning a **list of results**."),
  codemirror( "map(x->x*x, 1:4) == [1,4,9,16] ", language = "julia"),
)"""

weightandtype_str = """vbox(
  hbox(map(x->fontweight(x,"Sans \$x."), 100:200:900 )...),
  hbox(map(x->fontweight(x,"Mono \$x.") |> fonttype(monospace), 100:200:900 )...),
  hbox(map(x->fontweight(x,"Serif \$x.") |> fonttype(serif), 100:200:900 )...),
  fontweight(bold, "Bold flavored text"),
)"""

articles_str = """vbox(
  title(4,"Title 4"),
  map(n->title(n,"Title \$n"), 3:-1:1 )...,
  heading(1,"Heading 1"),
  map(n->heading(n,"Heading \$n"), 2:4 )...,
  "Body Text",
  h1( "h1(x) is short for header(1,x)" ),
  h2( "h2" ),
  h3( "h3" ),
  h4( "h4" ),
  md\"\"\"# Heading 1 in Markdown
  ## Heading 2 in Markdown
  ### Heading 3 in Markdown
  #### Heading 4 in Markdown\"\"\",
)"""

styles_str = """vbox(
  fontstyle(italic,"italics is a CSS class used for styling text"),
  emph("emphasis is an HTML tag for adding semantic emphasis to a word or phrase"),
  textalign(centertext,fontcase(ucase, "Loudness equals power." )),
  fontcase(lcase, "Speak softly, and carry a BIG stick." ) |> textalign(raggedleft),
  lineheight(80px,"This text has a high lineheight"),
)"""

colors_str = """using Colors
hbox(
  map(h->fontcolor(LCHab(50,200,h),"nya "),20:20:320)...,
  fontcolor(colorant"magenta","ncat :3")
) |> fontfamily("Ubuntu")"""

isinstalled(pkg) = try Pkg.installed(pkg) != nothing catch e false end

function main(window)
    push!(window.assets, "widgets")
    push!(window.assets, "codemirror")
    push!(window.assets, "tex")

    vbox(
        title(3, "Typography"),
        vskip(1em),
        md"Escher provides primitives that directly map to CSS font styling properties, as well as higher-level functions which form a standard typographic scale you can use to give your documents a consistent, pleasant look. By default, Escher uses the [*Source Sans Pro*](http://www.google.com/fonts/specimen/Source+Sans+Pro) (sans-serif) and [*Source Code Pro*](http://www.google.com/fonts/specimen/Source+Code+Pro) (monospaced) font families for great-looking and legible type.",
        vskip(1em),
        h1("High-level Functions"),
        md"""These use styles from $(Pkg.dir("Escher"))/assets/font.css by default""",

        vskip(1em),
        h2("Miscellaneous"),
        vskip(1em),
        listing(various_str),


        vskip(1em),
        h2("Titles and headings"),
        "Useful things you might use if writing an article like this one",
        vskip(1em),
        listing(articles_str),


        vskip(1em),
        h1("Low-level Functions"),
        "Sometimes you want more explicit control over your document",

        vskip(1em),
        h2("Weights and types"),
        md"Many classes of fonts are available, often with many weights. By default, Escher uses the [*Source Sans Pro*](http://www.google.com/fonts/specimen/Source+Sans+Pro) (sans-serif) and [*Source Code Pro*](http://www.google.com/fonts/specimen/Source+Code+Pro) (monospaced) font families for great-looking and legible type.",
        vskip(1em),
        listing(weightandtype_str),

        vskip(1em),
        h2("Styling and Alignment"),
        "For those time where your squiggly lines are leaning, or if you want to write on the other side",
        md"Valid alignments are ```raggedright```, ```raggedleft```, ```justifytext```, and ```centertext```",
        vskip(1em),
        listing(styles_str),

        vskip(1em),
        h2("Colors and Families"),
        md"You can also change the color of text with *fontcolor* and [Colors.jl](https://github.com/JuliaGraphics/Colors.jl). You may change the family with *fontfamily*",
        vskip(1em),
        listing(colors_str),

        vskip(1em),
        h2("Size"),
        md"```fontsize``` accepts many units of length",
        listing("""vbox(
  Escher.fontsize(xxlarge,"Big Text"),
  Escher.fontsize(3em,"Bigger Text"),
  Escher.fontsize(48px,"Bigger Text"),
)"""),

        vskip(1em),
        h1("Redundant sections from content.jl"),
        md"*EDITOR'S NOTE*: This section has potential reuse value should we decide to restructure it",
        h2("Code"),
        md"""To show code with syntax highlighting, you can use the `codemirror` function. Codemirror requires the `"codemirror"` asset. 
        
        Use `push!(window.assets, "codemirror")` to do this.""",
        vskip(1em),
        listing("""
            push!(window.assets, "codemirror")
            
            codemirror(\"\"\"
                function foo()
                42
                end
                \"\"\"
            )
            """,
            codemirror("""
                function foo()
                    42
                end
                """
            )
        ),
        md"""Note that you also need the `"codemirror"` asset to be loaded even if you are writing code inside `md`.""",

        vskip(1em),
        h2("LaTeX"),
        md"LaTeX strings can be rendered with the `tex` function.",
        vskip(1em),
        listing("""
        tex("(a+b)^2=a^2+b^2+2ab")"""),
        

    ) |> pad(2em)
end
