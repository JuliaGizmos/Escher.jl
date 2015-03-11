using Canvas
using DataFrames
import Gadfly: plot, Geom

import Canvas.render

clicks = Input(0)
phase = Input(0.0)

x = [0:0.01:2pi]

main = lift(phase) do ϕ
    data = DataFrame(x=x, y=sin(ϕ + x))
    vbox(headline("Table"),
        slider(0:0.01:2pi) |> phase,
        font(monospace, hbox(table(data), plot(data, x=:x, y=:y, Geom.line))),
    ) |> pad(0.5Canvas.inch)
end
