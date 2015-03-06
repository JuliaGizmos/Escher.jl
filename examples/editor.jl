using Canvas

code = Input("")

main = lift(code) do c
    vbox(
        codemirror(linenumbers=true, mode="julia") |> height(300px),
        vskip(1inch),
        Elem(:pre, c),
        vskip(1inch),
    )
end
