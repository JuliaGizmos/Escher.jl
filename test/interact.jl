import Escher: @api, @d, Behavior, Interpreter, boolattr

@api draggable => (Draggable <: Behavior) begin
    arg(tile::Tile)
    kwarg(name::Symbol=:drags)
    kwarg(disabled::Bool=false)
    kwarg(updateon::String="move")
    kwarg(reflect::Bool=true)
end

immutable Drag
    dx::Int
    dy::Int
    ddx::Float64
    ddy::Float64
end

immutable DragInterpreter <: Interpreter
end

Escher.default_interpreter(::Draggable) = DragInterpreter()

Escher.interpret(::DragInterpreter, dict) =
    Drag(dict["displacement"][1], dict["displacement"][2],
         dict["velocity"][1], dict["velocity"][2])

Escher.render(d::Draggable, state) =
    render(d.tile, state) << Elem("escher-draggable", attributes=@d(
        :name => d.name,
        :disabled => boolattr(d.disabled),
        :eventType => d.updateon,
        :reflect => boolattr(d.reflect),
    ))

@api resizable => (Resizable <: Behavior) begin
    arg(tile::Tile)
    kwarg(name::Symbol=:resizes)
    kwarg(disabled::Bool=false)
    kwarg(preserve_ratio::Bool=false)
    kwarg(updateon::String="move")
    kwarg(reflect::Bool=true)
end

immutable Resize
    w::Float64
    h::Float64
    dx::Float64
    dy::Float64
    ddx::Float64
    ddy::Float64
end

immutable ResizeInterpreter <: Interpreter
end

Escher.default_interpreter(::Resizable) = ResizeInterpreter()

Escher.interpret(::ResizeInterpreter, dict) =
    Resize(dict["size"][1], dict["size"][2],
        dict["offset"][1], dict["offset"][2],
        dict["velocity"][1], dict["velocity"][2])

Escher.render(r::Resizable, state) =
    render(r.tile,state) << Elem("escher-resizable", attributes=@d(
        :name => r.name,
        :disabled => boolattr(r.disabled),
        :eventType => r.updateon,
        :reflect => boolattr(r.reflect),
        :preserveAspectRatio => boolattr(r.preserve_ratio),
    ))

function circ(args...; kwargs...)
    Elem(:svg, :circle, args...; kwargs...)
end
function svg(args... ;kwargs...)
    Elem(:svg, :svg, args...; kwargs...)
end
function rect(args..., ;kwargs...)
    Elem(:svg, :rect, args...; kwargs...)
end

function projection(pos)
    # projection on the circle
end


function matellipse(A)
    [cos(X) sin(X)] * A
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
    push!(window.assets, "interact")
    d = Input{Any}(nothing)
    r = Input{Any}(nothing)
    cumpos = foldl((300.0, 200.0), d) do acc, disp
        x, y = acc[1] + disp.dx, acc[2] + disp.dy
        θ = atan2(y-200, x-200)
        (100*cos(θ) + 200, 100*sin(θ) + 200)
    end

    A = [1 3
         4 2] /4

    lift(cumpos) do p′
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
end
