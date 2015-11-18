function main(window)
    push!(window.assets, "widgets")

    inp = Signal(Dict())

    s = sampler()
    form = vbox(
        h1("Submit your rating"),
        watch!(s, :name, textinput("", label="Your name")),
        hbox("Your rating", watch!(s, :rating, slider(1:10)))
            |> packacross(center),
        trigger!(s, :submit, button("Submit"))
    ) |> maxwidth(400px)

    lift(inp) do dict
        vbox(
            Escher.capture(s, form) >>> inp,
            vskip(2em),
            string(dict)
        ) |> pad(2em)
    end
end
