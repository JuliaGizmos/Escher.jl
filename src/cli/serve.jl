#!/usr/bin/env julia
#
# Webapp
using Compat
using Mux
using JSON

using Reactive
using Patchwork

function loadfile(filename)
    if isfile(filename)
        try
            ui = include(filename)
            if typeof(ui) == Function
                return ui
            else
                warn("$filename did not return a function")
                return (w) -> Elem(:p, string(
                    filename, " did not return a UI function"
                ))
            end
        catch err
            bt = backtrace()
            return (win) -> Elem(:pre, sprint() do io
                showerror(io, err)
                Base.show_backtrace(io, bt)
            end)
        end
    else
        return (w) -> Elem(:p, string(
            filename, " could not be found."
        ))
    end
end

function setup_socket(file)
    io = IOBuffer()
    write(io, """<!doctype html>
    <html>
        <head>
        <meta charset="utf-8">
        """)
    # Include the basics
    write(io, "<script>", Patchwork.js_runtime(), "</script>")
    write(io, """<script src="/assets/bower_components/webcomponentsjs/webcomponents.min.js"></script>""")
    write(io, """<link rel="import" href="$(Escher.resolve_asset("basics"))">""")

    write(io, """</head> <body fullbleed unresolved><div id="root"></div>""")
    write(io, """<script>window.addEventListener('polymer-ready', function(e) {
          new Escherd($(JSON.json(file)), "root");
    })</script>""")
    takebuf_string(io)
end

mount_cmd(node, id="root") =
   [ "command" => "mount",
    "id" => id,
    "data" => Patchwork.jsonfmt(node)] |> JSON.json

import_cmd(asset) =
    [ "command" => "import",
      "data" => Escher.resolve_asset(asset) ] 

patch_cmd(diff, id="root") =
   [ "command" => "patch",
    "id" => id,
    "data" => Patchwork.jsonfmt(diff)] |> JSON.json

swap!(tilestream, next::Signal) =
    push!(tilestream, next)

swap!(tilestream, next) =
    push!(tilestream, Input(next))

const signals = Dict()
function Escher.setup_transport(x::Tuple)
    Escher.makeid(x)
end

const commands = Dict([
    ("signal-update", (window, msg) -> begin
        id = msg["data"]["signalId"]
        interp, sig = Escher.fromid(id)
        push!(sig, Escher.interpret(interp, msg["data"]["value"]))
    end),
    ("window-size", (window, msg) -> begin
        dim = (msg["data"][1] * Escher.px, msg["data"][2] * Escher.px)
        push!(window.dimension, dim)
    end),
    ("window-route", (window, msg) -> begin
        push!(window.route, msg["data"])
    end),
    ("window-kill", (window, msg) -> begin
        push!(window.alive, false)
    end),
])

query_dict(qstr) = begin
    parts = split(qstr, '&')
    dict = Dict()
    for p in parts
        k, v = split(p, "=")
        dict[k] = v
    end
    dict
end

uisocket(dir) = (req) -> begin
    file = joinpath(abspath(dir), (req[:params][:file]))

    d = query_dict(req[:query])

    w = @compat parse(Int, d["w"])
    h = @compat parse(Int, d["h"])

    sock = req[:socket]
    tilestream = Input{Signal}(Input{Tile}(empty))

    # TODO: Initialize window with session,
    # window dimensions and what not

    window = Window(dimension=(w*px, h*px))

    lift(asset -> write(sock, JSON.json(import_cmd(asset))),
         window.assets)

    main = loadfile(file)

    current = Escher.empty
    try
        current = main(window)
    catch err
        bt = backtrace()
        current = Elem(:pre, sprint() do io
            showerror(io, err)
            Base.show_backtrace(io, bt)
        end)
    end

    swap!(tilestream, current)

    rendered = render(current)
    try
        write(sock, mount_cmd(rendered))
    catch ex
        if isopen(sock)
            rethrow(ex)
        end
    end

    foldl(rendered, flatten(tilestream; typ=Any); typ=Any) do prev, next
        rendered_next = render(next)
        try
            write(sock, patch_cmd(
                Patchwork.diff(prev, rendered_next)))
        catch ex
            if isopen(sock)
                rethrow(ex)
            end
        end
        rendered_next
    end

    @async while isopen(sock)
        data = read(sock)

        msg = JSON.parse(bytestring(data))
        if !haskey(commands, msg["command"])
            warn("Unknown command received ", msg["command"])
        else
            commands[msg["command"]](window, msg)
        end
    end

    while isopen(sock)
        if !isfile(file)
            break
        end
        fw = watch_file(file)
        wait(fw)
        close(fw)
        sleep(0.05)

        main = loadfile(file)
        next = main(window)

        # Replace the current main signal
        swap!(tilestream, next)
    end

end

function escher_serve(port=5555, dir=".")
    # App
    @app static = (
        Mux.defaults,
        route("assets", Mux.files(Pkg.dir("Escher", "assets")), Mux.notfound()),
        route("/:file", req -> setup_socket(req[:params][:file])),
        route("/", req -> setup_socket("index.jl")),
        Mux.notfound(),
    )

    @app comm = (
        Mux.wdefaults,
        route("/socket/:file", uisocket(dir)),
        Mux.wclose,
        Mux.notfound(),
    )

    @sync serve(static, comm, port)
end
