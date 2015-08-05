include("helpers/repl.jl")

listing(code, output=showoutput(code)) = begin
    input = Input(code)
    cell = hbox(
        code_io(code, input) |> width(30em),
        hskip(0.5em),
        vline(),
        hskip(0.5em),
        vbox(
            lift(showoutput, input, typ=Any, init=output)
        ) |> wrap |> width(30em) |> Escher.pad(0.5em) |> fillcolor("white")
    ) |> Escher.pad(1em) |> paper(1)
    hbox(cell, flex())
end

hello_str = "\"Hello, World\""

md_str = """
md\"\"\"
## This is a heading

*italic*, **bold** and `monospace`.

- one
- two
- three

Code:

```julia
function foo()
    42
end
foo()
```
\"\"\" """

function main(window)
    push!(window.assets, "widgets")
    push!(window.assets, "codemirror")
    push!(window.assets, "tex")

    vbox(
        title(3, "Content"),

        vskip(1em),
        h2("String"),
        "A string is rendered as-is to plain text",
        vskip(1em),
        listing(hello_str),

        vskip(1em),
        h2("Markdown"),
        "Markdown strings get rendered appropriately.",
        vskip(1em),
        listing(md_str),

        vskip(1em),
        h2("LaTeX"),
        "LaTeX strings can be rendered with the `tex` function.",
        vskip(1em),
        listing("""
        tex("(a+b)^2=a^2+b^2+2ab")"""),

    ) |> pad(2em)
end
