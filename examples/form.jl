function main(window)
    push!(window.assets, "widgets")

    inp = Input(Dict())

    form = vbox(
        h1("Submit your rating"),
        broadcast(textinput("", name=:name, label="Your name")),
        hbox("Your rating", broadcast(slider(1:10, name=:rating)))
            |> packacross(center),
        broadcast(button("Submit", name=:submit))
    ) |> maxwidth(400px)

    lift(inp) do dict
        vbox(
            samplesignals([:name, :rating], :submit, form) >>> inp,
            vskip(2em),
            string(dict)
        ) |> pad(2em)
    end
end
