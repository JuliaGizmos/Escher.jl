write_patchwork_prelude(io::IO) =
    write(io, "<script>", Patchwork.js_runtime(), "</script>")

write_canvas_prelude(io::IO) = begin
    write(io, Canvas.custom_elements())
    write_patchwork_prelude(io)
end

@require Morsel begin
    # Allow route handlers to return Patchwork nodes

    import Meddle: MeddleRequest, Response

    function Morsel.prepare_response{ns, tag}(
            data::Elem{ns, tag}, req::MeddleRequest, res::Response)
        io = IOBuffer()
        Patchwork.write_patchwork_prelude(io)

        writemime(io, MIME"text/html"(), data)
        prepare_response(takebuf_string(io), req, res)
    end

    function Morsel.prepare_response(
            data::Tile, req::MeddleRequest, res::Response)

        io = IOBuffer()

        Canvas.write_canvas_prelude(io)

        writemime(io, MIME"text/html"(), render(data))
        prepare_response(takebuf_string(io), req, res)
    end
end

@require IJulia begin
    include(Pkg.dir("Canvas", "src", "ijulia.jl"))
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

    function convert(::Type{Tile}, p::Gadfly.Plot)
        backend = Compose.Patchable(
                     Compose.default_graphic_width,
                     Compose.default_graphic_height)
        convert(Tile, Compose.draw(backend, p))
    end
end

@require DataFrames begin
    include(Pkg.dir("Canvas", "src", "library", "table.jl"))
end
