import Compose: compose, context, polygon

function sierpinski(n)
    if n == 0
        Compose.compose(context(), polygon([(1,1), (0,1), (1/2, 0)]))
    else
        t = sierpinski(n - 1)
        Compose.compose(context(),
                (context(1/4,   0, 1/2, 1/2), t),
                (context(  0, 1/2, 1/2, 1/2), t),
                (context(1/2, 1/2, 1/2, 1/2), t))
    end
end

function main(window)
    push!(window.assets, "widgets")

    iterᵗ = Input(1)

    lift(iterᵗ) do iter
        vbox(title(2, "Sierpinski's Triangle"),
            vskip(1em),
            hbox("Iterations: ", slider(1:6) >>> iterᵗ),
            vskip(1em),
            sierpinski(iter),
        ) |> pad(2em)
    end
end
