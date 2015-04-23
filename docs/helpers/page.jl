
centeredpage(tile; padding=1em, widthcap=42em) =
    hbox(flex(), pad(1em, tile) |> maxwidth(widthcap), flex())
