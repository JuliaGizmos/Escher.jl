widgetbox(widget, init; typ=typeof(init)) = begin
    signal = Input{typ}(init)
    # Note: you need to pipe widget behavior to a signal
    #       *and* create a UI by lifting the same signal
    lift(x -> hbox(widget >>> signal, hskip(1em), string(x)) |>
              packacross(center), signal)
end

main(window) =
    vbox(
        title(2, "Widgets"),
        lift(vbox,
            widgetbox(button("Click me"), leftbutton),
            widgetbox(clickable([leftbutton, rightbutton, scrollbutton],
                    button("Click me with any button")),
                leftbutton, typ=Escher.MouseButton),
            widgetbox(textinput(), ""),
            widgetbox(slider(0:100), 0),
        )
    )
