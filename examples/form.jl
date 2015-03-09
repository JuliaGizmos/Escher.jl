using Canvas
using Reactive

data = Input(Dict())

main = lift(data) do x
    samplesignals([:rating, :name], :submit,
        vbox(
            headline("Submit your rating"),
            vskip(1em),
            textinput(label="Your Name", name=:name),
            hbox(vbox(flex(), "Your rating", flex()),
                 flex(slider(0:10, value=10, pin=true, name=:rating))),
            button("Submit", name=:submit),
            vskip(1cm),
            "Submitted data: ",
            pad(10px, string(x))) |> pad(2em) |> width(400px)
    ) |> data
end

