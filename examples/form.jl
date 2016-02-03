function main(window)
    push!(window.assets, "widgets")

    inp = Signal(Dict())

    s = Escher.sampler()
    form = vbox(
        h1("Submit your rating"),
        watch!(s, :name, textinput("", label="Your name")),
        hbox("Your rating", watch!(s, :rating, slider(1:10)))
            |> packacross(center),
        trigger!(s, :submit, button("Submit"))
    ) |> maxwidth(400px)

    map(inp) do dict
        vbox(
            intent(s, form) >>> inp,
            vskip(2em),
            string(dict)
        ) |> Escher.pad(2em)
    end
end
