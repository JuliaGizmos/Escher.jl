using Requires

write_patchwork_prelude(io::IO) =
    write(io, "<script>", Patchwork.js_runtime(), "</script>")

write_escher_prelude(io::IO) = begin
    write(io, Escher.custom_elements())
    write_patchwork_prelude(io)
end

# FIXME: figure out a way to make this work for Escher
#
# immutable EscherDisplay <: Base.Display end
#
# pushdisplay(EscherDisplay())

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

export drawing

@require Compose begin

    # A declarative version of draw?
    @api drawing => (ComposeGraphic <: Tile) begin
        arg(img::Any)
        curry(graphic::Any) # Either a plot or a compose node
    end
    drawing(w::Compose.Measure, h::Compose.Measure, p) =
        drawing(Compose.Patchable(w, h), p)

    drawing(w::Compose.Measure, h::Compose.Measure) = p -> drawing(w, h, p)

    drawing(p) =
        drawing(Compose.default_graphic_width, Compose.default_graphic_height, p)

    convert(::Type{Tile}, p::Compose.Context) =
        drawing(p)

    compose_render(img::Compose.Patchable, pic) = begin
        Compose.draw(img, pic)
    end

    compose_render(img, pic) = begin
        Compose.draw(img, pic) # do the drawing side-effect
        Elem(:img, src="""data:image/png;base64,$(base64(takebuf_array(img.out)))""")
    end

    render(d::ComposeGraphic, state) = begin
        Elem(:div, compose_render(d.img, d.graphic), className="graphic-wrap")
    end

end

@require Gadfly begin
    import Gadfly: Compose

    convert(::Type{Tile}, p::Gadfly.Plot) =
        drawing(p)
end

@require DataFrames begin
    include(Pkg.dir("Escher", "src", "library", "table.jl"))

    import DataFrames: AbstractDataFrame

    convert(::Type{Tile}, df::AbstractDataFrame) = table(df)
end

@require Blink begin
    include("blink.jl")
end

@require SymPy begin
    convert(::Type{Tile}, s::SymPy.Sym) =
        tex(SymPy.latex(s))
end
