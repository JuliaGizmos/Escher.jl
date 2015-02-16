
# Allow route handlers to return Patchwork nodes

import Meddle: MeddleRequest, Response
import Morsel: prepare_response

import Patchwork: Elem
import Canvas: Tile, render

function prepare_response{ns, tag}(
        data::Elem{ns, tag}, req::MeddleRequest, res::Response)
    io = IOBuffer()
    write(io, "<script>", Patchwork.js_runtime(), "</script>")
    writemime(io, MIME"text/html"(), data)
    prepare_response(takebuf_string(io), req, res)
end

function prepare_response(
        data::Tile, req::MeddleRequest, res::Response)

    io = IOBuffer()
    write(io, Canvas.custom_elements())
    write(io, "<script>", Patchwork.js_runtime(), "</script>")
    writemime(io, MIME"text/html"(), render(data))
    prepare_response(takebuf_string(io), req, res)
end
