
key_input = Signal(Key, nokey)

function main(window)
    cont = container(40em, 40em) |> fillcolor("#f1f3f1")
    box = inset(Escher.middle, cont, vbox(md"**Focus and press w, a, s, d or arrow keys**", key_input))

    keypress("w a s d up down left right", box) >>> key_input
end
