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
    render(d.tile, state) << Elem("escher-draggable",
        name = d.name,
        disabled = boolattr(d.disabled),
        eventType = d.updateon,
        reflect = d.reflect,
    )

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

using Compose

immutable EscherWrapper <: Compose.FormPrimitive
    tile::Tile
    render_state::Any
end
typealias EscherTile Compose.Form{EscherWrapper}
escher_wrap(t) = EscherTile([EscherWrapper(t, nothing)])

Compose.absolute_units(x::EscherWrapper, t::Compose.Transform, u::Compose.UnitBox, b::Compose.AbsoluteBoundingBox) = EscherWrapper(x.tile, (t, u, b))
Compose.compose(x::Compose.Context, y::Escher.Tile) = compose(context(), escher_wrap(y))

Compose.draw(img::Compose.Patchable, prim::EscherWrapper) =
    Escher.render(prim.tile, Dict(:img => img, :unit_args => prim.render_state))

immutable ComposeWrapper <: Tile
    compose_object::Compose.Form
end

Base.convert(::Type{Tile}, t::Compose.Form) =
    ComposeWrapper(t)

immutable BroadcastContainer
    array::AbstractArray
end

Patchwork.(:<<)(l::BroadcastContainer, x) = [a<<x for a in l.array]
Patchwork.(:&)(l::BroadcastContainer, x) = [a&x for a in l.array]

Escher.render(x::ComposeWrapper, state) = begin
    if Compose.isscalar(x.compose_object)
        draw(state[:img], Compose.absolute_units(x.compose_object.primitives[1], state[:unit_args]...))
    else
        BroadcastContainer([draw(state[:img], Compose.absolute_units(x, state[:unit_args]...)) for x in x.compose_object.primitives])
    end
end

Escher.external_setup()

function sierpinski(n)
    if n == 0
        Compose.compose(context(), polygon([(1,1), (0,1), (1/2, 0)]) |> draggable)
    else
        t = sierpinski(n - 1)
        Compose.compose(context(),
                (context(1/4,   0, 1/2, 1/2), t),
                (context(  0, 1/2, 1/2, 1/2), t),
                (context(1/2, 1/2, 1/2, 1/2), t))
    end
end

x = Input{Any}(nothing)
function main(w)
    push!(w.assets, "interact")
    sierpinski(2)
    compose(context(), circle([0.5,0.3,0.4],[0.5,0.3,0.4], [0.05,0.02,0.01]) |> draggable)
end
