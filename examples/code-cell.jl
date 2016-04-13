
function main(window)
    push!(window.assets, "codemirror")
    inp = Signal(Dict())

    s = sampler() # A thing that lets you watch widgets/behaviors upon updates to other behaviors

    editor = watch!(s, :code, codemirror("some code"))
    code_cell = trigger!(s, :submit, keypress("ctrl+enter shift+enter", editor))

    vbox(
        intent(s, code_cell) >>> inp,
        inp
    )
end
