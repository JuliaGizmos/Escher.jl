#!/usr/bin/env julia
#
# Webapp
using Compat
using Requires
using Mux
using JSON

using Reactive
using Patchwork

import Mux: @d

function loadfile(filename)
    if isfile(filename)
        try
            ui = include(filename)
            if isa(ui, Function)
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
    write(io, """<script src="/pkg/Escher/bower_components/webcomponentsjs/webcomponents.min.js"></script>""")
    write(io, """<link rel="import" href="$(Escher.resolve_asset("basics"))">""")

    write(io, """</head> <body fullbleed unresolved>""")
    write(io, """<script>window.addEventListener('WebComponentsReady', function(e) {
      Escher.init($(JSON.json(file)));
    })
    </script>
    <signal-container signal-id="root"></signal-container>
    </body>
    </html>""")
    takebuf_string(io)
end

mount_cmd(node, id="root") =
   @d( "command" => "mount",
    "id" => id,
    "data" => Patchwork.jsonfmt(node)) |> JSON.json

import_cmd(asset) =
    @d( "command" => "import",
      "data" => Escher.resolve_asset(asset) )

patch_cmd(id, diff) =
   @d( "command" => "patch",
    "id" => id,
    "data" => Patchwork.jsonfmt(diff) ) |> JSON.json

swap!(tilestream, next::Signal) =
    push!(tilestream, next)

swap!(tilestream, next) =
    push!(tilestream, Signal(next))

const commands = Dict([
    ("signal-update", (window, msg) -> begin
        id = msg["data"]["signalId"]
        sig, interp = Escher.fromid(id)
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

start_updates(sig, window, sock, id=Escher.makeid(sig)) = begin

    state = Dict()
    state["embedded_signals"] = Dict()
    init = render(value(sig), state)

    write(sock, patch_cmd(id, Patchwork.diff(render(Escher.empty, state), init)))

    foldp(init, filterwhen(window.alive, empty, sig); typ=Any) do prev, next

        st = Dict()
        st["embedded_signals"] = Dict()
        rendered_next = render(next, st)

        try
            write(sock, patch_cmd(id, Patchwork.diff(prev, rendered_next)))
        catch ex
            if isopen(sock)
                rethrow(ex)
            end
        end
        for (key, embedded) in st["embedded_signals"]
            start_updates(embedded, window, sock, key)
        end

        rendered_next
    end |> preserve

    for (key, embedded) in state["embedded_signals"]
        start_updates(embedded, window, sock, key)
    end
end


uisocket(dir) = (req) -> begin
    file = joinpath(abspath(dir), (req[:params][:file]))

    d = query_dict(req[:query])

    w = @compat parse(Int, d["w"])
    h = @compat parse(Int, d["h"])

    sock = req[:socket]
    tilestream = Signal(Signal, Signal(Tile, empty))

    # TODO: Initialize window with session,
    # window dimensions and what not

    window = Window(dimension=(w*px, h*px))

    Reactive.foreach(asset -> write(sock, JSON.json(import_cmd(asset))),
         window.assets)

    main = loadfile(file)

    current = Escher.empty
    try
        current = main(window)
    catch err
        bt = backtrace()
        str = sprint() do io
            showerror(io, err)
            Base.show_backtrace(io, bt)
        end
        current = Elem(:pre, str )
        println( str )
    end

    start_updates(flatten(tilestream, typ=Any), window, sock, "root")

    swap!(tilestream, current)

    t = @async while isopen(sock)
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
        # wait and close are part of watch_file
        if( VERSION < v"0.4.0-dev" )
          wait(fw)
          close(fw)
        end
        sleep(0.05)

        main = loadfile(file)
        next = main(window)

        # Replace the current main signal
        swap!(tilestream, next)
    end
    wait(t)

end

# Return files from the requested package, in the supplied directory
packagefiles(dir, dirs=true) =
  branch(req -> Mux.validpath(Pkg.dir(req[:params][:pkg], dir), joinpath(req[:path]...), dirs=dirs),
         req -> Mux.fresp(joinpath(Pkg.dir(req[:params][:pkg], dir), req[:path]...)))


function escher_serve(port=5555, dir="")
    # App
    @app static = (
        Mux.defaults,
        route("pkg/:pkg", packagefiles("assets"), Mux.notfound()),
        route("assets", Mux.files("assets"), Mux.notfound()),
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
