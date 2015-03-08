using Canvas
using Reactive

data = Input(Dict())

main = lift(data) do x
    samplesignals([:rating, :name], :submit,
        vbox(
            "Submit your rating" |> font(sansserif, huge, bold),
            textinput(label="Your Name", name=:name),
            hbox("Your rating", flex(slider(0:10, value=10, pin=true, name=:rating))),
            button("Submit", name=:submit),
            vskip(1cm),
            "Submitted data: ",
            pad(10px, string(x))) |> pad(1inch)
    ) |> data
end

