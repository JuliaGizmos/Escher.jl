using Canvas

code_signal = Input("")

main = lift(code_signal) do c
    vbox(
        h1("Eval something"),
        (codemirror(linenumbers=true, language="julia") |> code_signal)|> height(300px),
        vskip(1inch),
        Elem(:pre, c),
        vskip(1inch),
    ) |> pad(2em)
end
