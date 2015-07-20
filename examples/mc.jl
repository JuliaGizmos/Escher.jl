using Gadfly
using Markdown
using Distributions


N = Input(10000)
btn = Input{Escher.MouseButton}(leftbutton)
it = Input([0])
val = Input([1.0])
running = Input(false)
result = lift(st -> run_simulate() , btn; typ=Any, init=nothing)

f(u) = exp(-u^2/2)/√(2pi)


f(u) = exp(-u^2/2)/√(2pi)

const u1=Uniform(-5.0,+5.0)
const u2=Uniform(0.0, 0.5)

function simulate_pt()
    x=rand(u1)
    y=rand(u2)
    y<f(x)
end

#The main numerical method
#external interface to visualisation is:
#start, interim, finished
#Thus, the numerics has very limited coupling with the visualisation
function simulate(num)
     initiate()
     hits=0
     for (i in 1:num)
        hits = hits + simulate_pt()
        if (i % 10000) == 0
            interim(i, hits/i*(0.5*10) )
        end
    end
    estimate = hits/num*(0.5*10)
    finished(estimate)
end

function run_simulate()
    println("Starting Simulations for N=$(value(N))")
    @async simulate(value(N))
end

function interim(k,v) 
    push!(it, push!(value(it), k))
    push!(val, push!(value(val), v))

end

function finished(v)
    push!(running, false)
end

function initiate()
    push!(running, true)
end

function main(window)
    push!(window.assets, "tex")
    push!(window.assets, "widgets")

    lift( it, val, running) do  i, v, r
        vbox(h1("Interactive Simulations"),
            hbox(vbox(
                     md"""We want to estimate the following integral using a
                     *Monte Carlo* Simulation""",
                     hbox(tex("\\int_{-5}^{5} \\frac{exp(-u^2/2)}{\\sqrt{2pi}}du" , block=true) ),
                     ),
                plot(f, -5, +5, Theme(line_width=2Gadfly.mm, major_label_font_size=40Gadfly.px, minor_label_font_size=25Gadfly.px)) |> size(60em, 60em),
             ),
             hbox("Number of runs", slider(10^3:10^3:10^6) >>> N, hskip(5em), hbox(button("Start", raised=true, disabled=r) >>> btn)) |> packacross(center),            
             hbox("Current value: ", hskip(1em), @sprintf("%2.4f", v[end]) |> emph, hskip(1em)," at iteration :", hskip(1em), string(i[end])),
             plot(x=i, y=v)) |> pad(2em) 
    end
end

