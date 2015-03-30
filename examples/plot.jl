using Gadfly

ϕ = Input(0.0)

function main(window)
    push!(window.assets, "widgets")

    lift(ϕ) do phase
        vbox(h1("Interactive plotting"),
             hbox("Set the phase", slider(0:.01:2π) >>> ϕ) |> packacross(center),
             plot([x -> sin(x + phase), x -> cos(x + phase)], 0, 6)) |> pad(2em)
    end
end
