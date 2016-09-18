using Colors
include("helpers/listing.jl")

isinstalled(pkg) = try Pkg.installed(pkg) != nothing catch e false end

function main(window)
    push!(window.assets, "widgets")
    push!(window.assets, "codemirror")
    push!(window.assets, "tex")

    vbox(
        title(3, "Typography"),
        vskip(1em),
        md"Escher provides primitives that directly map to CSS font styling properties, as well as higher-level functions which form a standard typographic scale you can use to give your documents a consistent aesthetic.",
        vskip(1em),
        h1("High-level Functions"),
        md"""These use styles from $(Pkg.dir("Escher"))/assets/font.css by default""", # It would be better to have the served asset directory instead

        vskip(1em),
        h2("Block Quotes"),
        md"Block quotes is a style used when quoting large sections of text. They are also available within markdown by prepending a section with `>` ",
        vskip(1em),
        listing("""vbox(
          blockquote(md" `map` is a function that that applies a given **function** to each element of a **list**, returning a **list of results**."),
          md"e.g. `map(x->x*x, 1:4)` evaluates to \$(string(map(x->x*x, 1:4)))",
        )
        """),


        vskip(1em),
        h2("Titles and Headings"),
        "Useful things you might use if writing an article like this one",
        vskip(1em),
        listing("""vbox(
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
)"""),

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

        vskip(1em),
        h1("Low-level Functions"),
        "Sometimes you want more explicit control over your document",

        vskip(1em),
        h2("Weights and Types"),
        md"Many classes of fonts are available, often with many weights. By default, Escher uses the [*Source Sans Pro*](http://www.google.com/fonts/specimen/Source+Sans+Pro) (sans-serif) and [*Source Code Pro*](http://www.google.com/fonts/specimen/Source+Code+Pro) (monospaced) font families for great-looking and legible type.",
md"`fontweight` can take integer multiples of 100 from 100 to 900, or values such as `bold`, `bolder`, and `lighter` ",
md"`fonttype` arguments include `serif`, `sansserif`, `slabserif`, and `monospace`.",
        vskip(1em),
        listing("""hbox(intersperse(hskip(1em),[
  vbox(map(x->fontweight(x,"Sans \$x."), 100:200:700 )...),
  vbox(map(x->fontweight(x,"Mono \$x.") |> fonttype(monospace), 300:200:700 )...),
  vbox(map(x->fontweight(x,"Serif \$x.") |> fonttype(serif), 500:200:700 )...),
  fontweight(bold, "Bold flavored text")
]))"""),

        vskip(1em),
        h2("Styling and Alignment"),
        "For those time where your squiggly lines are leaning, or if you want to write on the other side",
        md"Valid alignments are `raggedright`, `raggedleft`, `justifytext`, and `centertext`",
        md"note that `fontcase` only changes the style, and not the content of the text. Valid arguments are `ucase` and `lcase`",
        vskip(1em),
        listing("""vbox(
  fontstyle(italic,"italics is a CSS class used for styling text"),
  emph("emphasis is an HTML tag for adding semantic emphasis to a word or phrase"),
  textalign(centertext,fontcase(ucase, "Loudness equals power." )),
  fontcase(lcase, "Speak softly, and carry a BIG stick." ) |> textalign(raggedleft),
  lineheight(80px,"This text has a high lineheight"),
)"""),

        vskip(1em),
        h2("Colors and Families"),
        md"You can also change the color of text with *fontcolor* and [Colors.jl](https://github.com/JuliaGraphics/Colors.jl). You may change the family with *fontfamily*",
        vskip(1em),
        listing("""using Colors
hbox(
  map(h->fontcolor(LCHab(50,200,h),"nya "),20:20:320)...,
  fontcolor(colorant"magenta","ncat :3")
) |> fontfamily("Ubuntu")"""),

        vskip(1em),
        h2("Size"),
        md"```fontsize``` accepts many units of length such as `pt` and `px`, as well as keywords `((x)x)large|small` and `medium`",
        listing("""vbox(
  Escher.fontsize(xxlarge,"Big Text"),
  Escher.fontsize(36pt,"Bigger Text"),
  Escher.fontsize(48px,"Bigger Text"),
)"""),
        vskip(1em),
        
        title(3, "Embellishment"),
        vskip(1em),

md"A border may be styled by many functions. `borderstyle` may accept `solid`, `dashed`, `dotted`, and `noborder`. `fillcolor` and `bordercolor` can accept any color defined in colors.jl, and `borderwidth` may accept anything of type Length such as `em` or `px`.",
        listing("""greybox = container(12em,2.5em) |> fillcolor(colorant"grey") |> borderwidth(0.4em)
 
vbox(
 greybox,
 greybox |> bordercolor(colorant"orange") |> borderstyle(solid),
 greybox |> borderstyle(solid),
 greybox |> borderstyle(dotted),
 greybox |> borderstyle(dashed),
)"""),

        vskip(1em),
md"You may specify a border all at once with `border`. It takes a list of sides (optionally), a style, a width, and a color.",
        listing("""image(
    "https://upload.wikimedia.org/wikipedia/commons/thumb/5/5f/Utah_teapot_simple_2.png/220px-Utah_teapot_simple_2.png",
    alt="Teapot",
) |> border([right,top,left,bottom],dashed,2px,colorant"#2D2E30")"""),

        vskip(1em),
        md"`hline` and `vline` are very thin, bordered elements that are inteded for use as a separator. It is quite useful within a flow: `vline` within a `hbox` and `hline` in a `vbox`. As with any other bordered element, they can be styled accordingly",
        listing("""vbox(
          paper(4,hbox(
            [
              flex("Column A"),
              vline(),
              flex("Column B")
            ]
          )),
          vskip(4em),
          paper(4,vbox(
            [
              "Row 1",
              hline() |> borderwidth(3px),
              "Row 2"
            ]
          )),
        )"""),

    ) |> pad(2em)
end
