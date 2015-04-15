using Gadfly

ϕᵗ = Input(0.0)

function main(window)
    push!(window.assets, "widgets")

    lift(ϕᵗ) do ϕ
        vbox(h1("Interactive plotting"),
             hbox("Set the phase", slider(0:.01:2π) >>> ϕᵗ) |> packacross(center),
             plot([x -> sin(x + ϕ), x -> cos(x + ϕ)], 0, 6)) |> pad(2em)
    end
end
