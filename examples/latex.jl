tex = Input("f(x) = \\int_{-\\infty}^\\infty
           \\hat f(\\xi)\\,e^{2 \\pi i \\xi x}
           \\,d\\xi")
mode = Input(false)

function main(window)
    push!(window.assets, "latex")
    push!(window.assets, "widgets")

    lift(tex, mode) do t, m
        vbox(h1("LaTeX"),
             hbox("LaTeX support is via ", hskip(1em), latex("\\KaTeX")),
             textinput(t) |> tex,
             hbox("Show as a block", hskip(1em), checkbox(value=m) |> mode),
             vskip(1em),
             latex(t, block=m)) |> pad(1em) |> maxwidth(800px)
    end
end
