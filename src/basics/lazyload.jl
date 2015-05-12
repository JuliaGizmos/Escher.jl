using Requires

write_patchwork_prelude(io::IO) =
    write(io, "<script>", Patchwork.js_runtime(), "</script>")

write_escher_prelude(io::IO) = begin
    write(io, Escher.custom_elements())
    write_patchwork_prelude(io)
end

@require Morsel begin
    # Allow route handlers to return Patchwork nodes

    import Meddle: MeddleRequest, Response

    Morsel.prepare_response{ns, tag}(
        data::Elem{ns, tag}, req::MeddleRequest, res::Response,
    ) = begin
        io = IOBuffer()
        Patchwork.write_patchwork_prelude(io)

        writemime(io, MIME"text/html"(), data)
        prepare_response(takebuf_string(io), req, res)
    end

    Morsel.prepare_response(
        data::Tile, req::MeddleRequest, res::Response,
    ) = begin

        io = IOBuffer()

        Escher.write_escher_prelude(io)

        writemime(io, MIME"text/html"(), render(data))
        prepare_response(takebuf_string(io), req, res)
    end
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

    convert(::Type{Tile}, p::Gadfly.Plot) = begin
        backend = Compose.Patchable(
            Compose.default_graphic_width,
            Compose.default_graphic_height,
        )
        convert(Tile, Compose.draw(backend, p))
    end
end

@require Compose begin

    convert(::Type{Tile}, p::Compose.Context) = begin
        backend = Compose.Patchable(
            Compose.default_graphic_width,
            Compose.default_graphic_height,
        )
        convert(Tile, Compose.draw(backend, p))
    end
end

@require DataFrames begin
    include(Pkg.dir("Escher", "src", "library", "table.jl"))

    import DataFrames: AbstractDataFrame

    convert(::Type{Tile}, df::AbstractDataFrame) = table(df)
end
