
fig(x) = pad(1em, x)

docpage(tile; padding=2em, widthcap=50em) =
    hbox(flex(), pad(4em, tile) |> maxwidth(widthcap), flex())
