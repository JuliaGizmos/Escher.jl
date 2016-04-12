include("../cli/serverutil.jl")

using Mux, Blink, Reactive

Blink.set_user_middleware!(route("/pkg/:pkg", packagefiles("assets"), Mux.notfound()))

windowpairs = Dict() # todo: make sure to pop! window closes
function preparewindow(blinkwin::Blink.Window)
    if haskey(windowpairs, blinkwin)
        return windowpairs[blinkwin]
    end
    @show w = @js blinkwin window.innerWidth
    @show h = @js blinkwin window.innerHeight

    #loadjs!(blinkwin, joinpath("pkg", "Escher", "bower_components/webcomponentsjs/webcomponents.min.js"))
    importhtml!(blinkwin, joinpath("pkg", "Escher", "basics.html"))

    stream = Signal(Signal, Signal(Tile, empty))
    win, stream = Base.@get! windowpairs blinkwin begin
      Escher.Window(blinkwin, dimension=(w*px, h*px)), stream
    end

    Reactive.foreach(win.assets) do asset
        path = Escher.resolve_asset(asset)
        importhtml!(blinkwin, path)
    end
    Blink.handle(win, "escher") do msg
        handle_command(win, msg)
    end
    start_updates(flatten(stream, typ=Any), win, "root")
    win, stream
end

function send_command(window::Escher.Window{Blink.Window}, x)

    @show "sending" x
    
    Blink.js_(window.output, :(window.Escher.recv($x)))
end

function showui(w::Blink.Window, ui)
    win,stream = preparewindow(w)
    swap!(stream, ui)
end
