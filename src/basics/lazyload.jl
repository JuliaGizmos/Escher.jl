using Requires

write_patchwork_prelude(io::IO) =
    write(io, "<script>", Patchwork.js_runtime(), "</script>")

write_escher_prelude(io::IO) = begin
    write(io, Escher.custom_elements())
    write_patchwork_prelude(io)
end

@require IJulia begin
    # Load custom element definitions

    using IJulia.CommManager
    import Base.Random: UUID, uuid4

    setup_transport(sig::Input) = begin
        id = makeid(sig)
        comm = Comm(:EscherSignal, data=@d(:signalId => id))
        comm.on_msg = (msg) ->
            push!(sig, decodeJSON(sig, msg.content["data"]["value"]))
        return id
    end
end

@require Blink begin
    # This is still defunct though
    import BlinkDisplay, Graphics

    Blink.windowinit() do w
        Blink.head(w, custom_elements())
    end

    Graphics.media(Tile, Graphics.Media.Graphical)
end

@require Gadfly begin
    import Gadfly: Compose

    convert(::Type{Tile}, p::Gadfly.Plot) =
        drawing(p)
end

export drawing

@require Compose begin

    @api drawing => ComposeGraphic <: Tile begin
        arg(width::Compose.Measure)
        arg(height::Compose.Measure)
        curry(graphic::Any) # Either a plot or a compose node
    end
    drawing(p) =
        drawing(Compose.default_graphic_width,
                Compose.default_graphic_height, p)

    convert(::Type{Tile}, p::Compose.Context) =
        drawing(p)

    render(d::ComposeGraphic, state) = begin
        backend = Compose.Patchable(
            d.width, d.height
        )
        Elem(:div, Compose.draw(backend, d.graphic), className="graphic-wrap")
    end
end

@require DataFrames begin
    include(Pkg.dir("Escher", "src", "library", "table.jl"))

    import DataFrames: AbstractDataFrame

    convert(::Type{Tile}, df::AbstractDataFrame) = table(df)
end
