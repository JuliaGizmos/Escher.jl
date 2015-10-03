using Gadfly
using Distributions

Escher.external_setup()

plot_beta(α, β) =
    plot(x -> pdf(Beta(α, β), x), 0, 1)

main(window) = begin
    push!(window.assets, "widgets")

    αᵗ = Input(1.0)
    βᵗ = Input(1.0)

    vbox(md"## Static Plot",
        drawing(4Gadfly.inch, 2Gadfly.inch, plot(sin, 0, 25)),
        md"## Dynamic plot",
        hbox("Alpha: " |>
            width(4em), slider(1:100) >>> αᵗ) |>
            packacross(center),
        hbox("Beta: "  |>
            width(4em), slider(1:100) >>> βᵗ) |>
            packacross(center),
        lift(αᵗ, βᵗ) do α, β
            plot_beta(α,β) |> drawing(4Gadfly.inch, 3Gadfly.inch)
        end
    ) |> pad(2em)
end
