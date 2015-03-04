using Canvas
using DataFrames
using Gadfly

import Canvas.render

data = DataFrame(x=[1:12], y=rand(12))
main = inset(
    Canvas.middle,
    snugfit(),
    flow(down, [h1("Table"),
        flow(right, [table(data), plot(data, x=:x, y=:y)]),
        button("Refresh") |> Canvas.clickable]))
