using Gadfly
using Distributions

plot_beta(α, β) =
    plot(x -> pdf(Beta(α, β), x), 0, 1)

main(window) = begin
    push!(window.assets, "widgets")

    αᵗ = Input(1.0)
    βᵗ = Input(1.0)

    vbox(md"## Static Plot",
        drawing(4inch, 2inch, plot(sin, 0, 25)),
        md"## Dynamic plot",
        hbox("Alpha: " |>
            width(4em), slider(1:100) >>> αᵗ) |>
            packacross(center),
        hbox("Beta: "  |>
            width(4em), slider(1:100) >>> βᵗ) |>
            packacross(center),
        lift(αᵗ, βᵗ) do α, β
            plot_beta(α,β) |> drawing(4inch, 3inch)
        end
    ) |> pad(2em)
end
