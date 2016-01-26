using Gadfly
using Distributions

f(u) = exp(-u^2/2)/√(2pi)

const curve_plot =
    plot(f, -5, +5,
        Theme(line_width=2Gadfly.mm,
              major_label_font_size=40Gadfly.px,
              minor_label_font_size=25Gadfly.px)
    )

const u1=Uniform(-5.0,+5.0)
const u2=Uniform(0.0, 0.5)

function simulate_pt()
    x=rand(u1)
    y=rand(u2)
    y<f(x)
end

function simulate(num, running, current_approx)
     push!(running, true)
     hits=0
     for (i in 1:num)
        hits = hits + simulate_pt()
        if (i % 10000) == 0
            push!(current_approx, (i, hits/i*(0.5*10) ))
        end
    end
    estimate = hits/num*(0.5*10)
    push!(running, false)
end

function run_simulate(N, running, current_approx)
    println("Starting Simulations for N=$N")
    @async simulate(N, running, current_approx)
end

function main(window)
    push!(window.assets, "tex")
    push!(window.assets, "widgets")

    N = Signal(10000)
    btn = Signal(Any, leftbutton)

    current_approx = Signal((0, 1.0)) # current approximation
    buffered_approx = foldp((Any[0],Any[1.0]), current_approx) do prev, current
        idx, val = current
        push!(prev[1], idx), push!(prev[2], val)
    end

    running = Signal(false)
    result = map(sampleon(btn, N); typ=Any, init=nothing) do n
        run_simulate(n, running, current_approx)
    end

    vbox(
        h1("Interactive Simulations"),
        hbox(
            vbox(
                 md"""We want to estimate the following integral using a
                 *Monte Carlo* Simulation""",
                 tex("\\int_{-5}^{5} \\frac{exp(-u^2/2)}{\\sqrt{2pi}}du" , block=true),
            ),
            curve_plot
         ) |> packacross(center),
         map(buffered_approx, running) do approx, r
             xs, ys = approx
             vbox(
                 hbox("Number of runs", slider(10^3:10^3:5*10^6) >>> N, hskip(2em), hbox(button("Start", raised=true, disabled=r) >>> btn)) |> packacross(center),
                 hbox("Current value: ", hskip(1em), @sprintf("%2.4f", ys[end]) |> emph, hskip(1em)," at iteration :", hskip(1em), string(xs[end])),
                 plot(x=xs, y=ys, Geom.line) |> pad(2em)
             )
         end
    ) |> pad(2em)
end
