function main(window)
    push!(window.assets, "widgets")

    inp = Signal(Dict())

    s = Escher.sampler()
    form = vbox(
        h1("How would you like your pizza?"),
        trigger!(s, watch!(s, :pepperoni, checkbox("Pepperoni?"))),
        trigger!(s, watch!(s, :mushrooms, checkbox("Mushrooms?"))),
        trigger!(s, watch!(s, :peppers, checkbox("Peppers?"))),
        trigger!(s, watch!(s, :anchovies, checkbox("Anchovies?"))),
    ) |> maxwidth(400px)

    map(inp) do dict
        vbox(
            intent(s, form) >>> inp,
            vskip(2em),
            string(dict)
        ) |> Escher.pad(2em)
    end
end
