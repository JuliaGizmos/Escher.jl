# An example code editor
# You can either click on "Submit code" button
# or hit Ctrl+R to update the input signal.

function main(window)
    push!(window.assets, "codemirror")
    push!(window.assets, "widgets")

    input = Input(Dict())
    s = sampler()
    editor = watch!(s, codemirror()) |>
        size(50vw, 90vh)
    submit = trigger!(s, button("Submit code"))

    form = plugsampler(s, vbox(editor, vskip(1em), submit)) >>> input
    
    lift(data -> hbox(form, string(data)), input)
end
