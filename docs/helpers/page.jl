
fig(x) = pad(1em, x)

docpage(tile; padding=2em, widthcap=62em) =
    hbox(pad(4em, tile) |> maxwidth(widthcap), flex())
