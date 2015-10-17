include("interact.jl")

function matrix_input()
    a_input = Input(1.0)
    b_input = Input(0.0)

    c_input = Input(0.0)
    d_input = Input(1.0)

    vbox(
        hbox(
            slider(-1:0.05:1, value=1) >>> a_input,
            slider(-1:0.05:1, value=0) >>> b_input,
        ),
        hbox(
            slider(-1:0.05:1, value=0) >>> c_input,
            slider(-1:0.05:1, value=1) >>> d_input,
        )
    ),

    consume(a_input, b_input, c_input, d_input) do a, b, c, d
        [a b; c d]
    end

end
function ellipse_plot(Y,col, linecol)
    x, y = Y[:, 1], Y[:, 2]
    #Elem(:svg, :path, d="M" * strip(join(["$(x[i]) $(y[i]) l" for i=1:length(x)], " "), ['l']), stroke="#900")
    l = Elem(:svg, :line, x1=200, y1=200, x2=x[end], y2=y[end], stroke=linecol)
    vcat([Elem(:svg, :circle, cx=x[i], cy=y[i], r=2, fill=col) for i=1:length(x)], l)
end

function mulpath(A, θ)
    if θ < 0
       θ = 2pi + θ
    end
    X = collect(0:0.1:θ)
    vcat(ellipse_plot([cos(X) sin(X)] * A .* 100 .+ 200, "#447", "#447"),
        ellipse_plot([cos(X) sin(X)] * [1 0; 0 1] .* 100 .+ 200, "#474", "#474"))
end

function arrow(x,y, c)
    Elem(:svg, :line, x1=200, y1=200, x2=x, y2=y, stroke=c)
end

function main(window)
    push!(window.assets, "widgets")
    push!(window.assets, "interact")
    d = Input{Any}(nothing)
    r = Input{Any}(nothing)
    cumpos = foldl((300.0, 200.0), d) do acc, disp
        x, y = acc[1] + disp.dx, acc[2] + disp.dy
        θ = atan2(y-200, x-200)
        (100*cos(θ) + 200, 100*sin(θ) + 200)
    end

    ui, A_input = matrix_input()

    vbox(
        title(2, md"`eigshow`" |> fontcolor("#bbb")),
        vskip(2em),
        ui,
        lift(cumpos, A_input) do p′, A
            θ = atan2(p′[2]-200, p′[1]-200)
        vbox(
            svg(Elem[
                circ(cx=200, cy=200, r=100, stroke="#ccc", fill="none"),
                    mulpath(A, θ)...,
                    draggable(circ(cx=p′[1], cy=p′[2], r=5, fill="#474"), reflect=false) >>> d |> x->render(x, Dict()),
                #resizable(draggable(rect(width=10,height=10), reflect=false) >>> d) >>> r |> x->render(x, Dict()),
            ], width=1000, height=400)
        )
        end
    ) |> Escher.pad(2em)
end
