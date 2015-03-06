using Canvas
using Reactive

data = Input(Dict())

main = lift(data) do x
    samplesignals([:rating, :name], :submit,
        vbox(
            h1("Submit your rating"),
            textinput(label="Your Name", name=:name),
            hbox(div("Your rating", style=[:whiteSpace=>:nowrap]), slider(0:10, value=10, pin=true, name=:rating)),
            button("Submit", name=:submit),
            vskip(1cm),
            "Submitted data: ",
            pad(10px, string(x))) |> pad(1inch)
    ) |> data
end

