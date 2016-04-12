

import_cmd(asset) =
    @d( "command" => "import",
      "data" => Escher.resolve_asset(asset) )

patch_cmd(id, diff) =
   @d( "command" => "patch",
    "id" => id,
    "data" => Patchwork.jsonfmt(diff) )


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

function handle_command(window, msg)
    if !haskey(commands, msg["command"])
        warn("Unknown command received ", msg["command"])
    else
        commands[msg["command"]](window, msg)
    end
end

packagefiles(dir, dirs=true) =
  branch(req -> Mux.validpath(Pkg.dir(req[:params][:pkg], dir), joinpath(req[:path]...), dirs=dirs),
         req -> Mux.fresp(joinpath(Pkg.dir(req[:params][:pkg], dir), req[:path]...)))

swap!(tilestream, next::Signal) =
    push!(tilestream, next)

swap!(tilestream, next) =
    push!(tilestream, Signal(next))

function start_updates(sig, window::Window, id=Escher.makeid(sig))
    sock = window.output

    state = Dict()
    state["embedded_signals"] = Dict()
    init = render(value(sig), state)

    send_command(window, patch_cmd(id, Patchwork.diff(render(Escher.empty, state), init)))

    foldp(init, filterwhen(window.alive, empty, sig); typ=Any) do prev, next

        st = Dict()
        st["embedded_signals"] = Dict()
        rendered_next = render(next, st)

        try
            send_command(window, patch_cmd(id, Patchwork.diff(prev, rendered_next)))
        catch ex
            if isopen(sock)
                rethrow(ex)
            end
        end
        for (key, embedded) in st["embedded_signals"]
            start_updates(embedded, window, key)
        end

        rendered_next
    end |> preserve

    for (key, embedded) in state["embedded_signals"]
        start_updates(embedded, window, key)
    end
end

