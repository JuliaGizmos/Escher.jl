function main(window)
    push!(window.assets, "widgets")

    inp = Input(Dict())

    s = sampler()
    form = vbox(
        h1("Submit your rating"),
        watch!(s, textinput("", name=:name, label="Your name")),
        hbox("Your rating", watch!(s, slider(1:10, name=:rating)))
            |> packacross(center),
        trigger!(s, button("Submit", name=:submit))
    ) |> maxwidth(400px)

    lift(inp) do dict
        vbox(
            sample(s, form) >>> inp,
            vskip(2em),
            string(dict)
        ) |> pad(2em)
    end
end
