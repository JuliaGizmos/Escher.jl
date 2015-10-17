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
end
typealias EscherTile Compose.Form{EscherWrapper}
escher_wrap(t) = EscherTile([EscherWrapper(t)])

Compose.draw(img::Compose.Patchable, prim::EscherWrapper) =
    Escher.render(prim.tile, Dict(:img => img))

Base.convert(::Compose.FormPrimitive, t::Union{Compose.Form, Compose.FormPrimitive, Compose.Context}) =
    EscherWrapper(t)


immutable ComposeWrapper <: Tile
    compose_object::Union{Compose.Form, Compose.Context}
end

Base.convert(::Type{Tile}, t::Union{Compose.Form, Compose.Context}) =
    ComposeWrapper(t)

Escher.render(x::ComposeWrapper, state) =
    draw(state[:img], x.compose_object)
Compose.absolute_units(x::EscherWrapper, ::Compose.Transform, ::Compose.UnitBox, ::Compose.AbsoluteBoundingBox) = x
Compose.compose(x::Compose.Context, y::Escher.Tile) = compose(context(), escher_wrap(y))

main(w) = compose(context(), draggable(circle()))
