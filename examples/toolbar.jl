using Canvas
using Markdown

import Canvas: @api, render

desc = md"""
# Hello, World!
You can write any **Markdown** text and place it in the middle of other
tiles.
""" |> pad(1inch)

main(window) = begin
    push!(window.assets, "layout2")
    push!(window.assets, "widgets")

    t, p = wire(tabs([hbox(icon("home"), hskip(1em), "Home"),
                      hbox(icon("info-outline"), hskip(1em),  "Notifications"),
                      hbox(icon("settings"), hskip(1em), "Settings")]),
                pages([desc, "b", "c"]), :lol, :selected)

    vbox(toolbar([iconbutton("face"), "My App", flex(), iconbutton("search")]),
         maxwidth(600px, t),
         pad(1em, p))
end
