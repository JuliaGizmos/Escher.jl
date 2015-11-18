
function main(window)
    push!(window.assets, "codemirror")
    inp = Signal(Dict())

    s = sampler() # A thing that lets you watch widgets/behaviors upon updates to other behaviors

    editor = watch!(s, codemirror("some code", name=:code))
    code_cell = trigger!(s, keypress("ctrl+enter shift+enter", editor))

    plugsampler(s,
       vbox(
           "My code cell",
           code_cell,
           inp,
       )
    ) >>> inp
end
