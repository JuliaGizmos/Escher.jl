include("repl.jl")

listing(code, output=showoutput(code)) = begin
    output = output == nothing ? showoutput(code) : output
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

