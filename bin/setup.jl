
# Allow route handlers to return Patchwork nodes

import Meddle: MeddleRequest, Response
import Morsel: prepare_response

import Patchwork: Elem
import Canvas: Tile, render

write_patchwork_prelude(io::IO) =
    write(io, "<script>", Patchwork.js_runtime(), "</script>")

write_canvas_prelude(io::IO) = begin
    write(io, Canvas.custom_elements())
    write_patchwork_prelude(io)
end

function prepare_response{ns, tag}(
        data::Elem{ns, tag}, req::MeddleRequest, res::Response)
    io = IOBuffer()
    write_patchwork_prelude(io)

    writemime(io, MIME"text/html"(), data)
    prepare_response(takebuf_string(io), req, res)
end

function prepare_response(
        data::Tile, req::MeddleRequest, res::Response)

    io = IOBuffer()

    write_canvas_prelude(io)

    writemime(io, MIME"text/html"(), render(data))
    prepare_response(takebuf_string(io), req, res)
end
