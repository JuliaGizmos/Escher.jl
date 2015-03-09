using Canvas
using DataFrames
using Gadfly

import Canvas.render

clicks = Input(0)
data_length = Input(10)

main = lift(data_length) do l
    data = DataFrame(x=[1:l], y=rand(l))
    vbox(h1("Table"),
        slider(1:1000) |> data_length,
        hbox(table(data), plot(data, x=:x, y=:y, Geom.line)),
    ) |> pad(0.5Canvas.inch)
end
