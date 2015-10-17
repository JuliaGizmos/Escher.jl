include("interact.jl")
function main(window)
    push!(window.assets, "interact")
    d = Input{Any}(nothing)
    r = Input{Any}(nothing)
    dr = Input{Any}(nothing)

    vbox(
        vbox(
            svg(Elem[
                    draggable(circ(cx=300, cy=200, r=25, fill="#474")) >>> d |> x->render(x, Dict()),
                resizable(draggable(rect(width=100,height=100, fill="orange"), reflect=false) >>> dr) >>> r |> x->render(x, Dict()),
            ], width=1000, height=400),
            d, r, dr
        )
    ) |> Escher.pad(2em)
end
