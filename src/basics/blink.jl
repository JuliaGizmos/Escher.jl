include("../cli/serverutil.jl")

using Mux, Blink, Reactive

Blink.set_user_middleware!(route("/pkg/:pkg", packagefiles("assets"), Mux.notfound()))

windowpairs = Dict() # todo: make sure to pop! window closes
function preparewindow(blinkwin::Blink.Window)
    if haskey(windowpairs, blinkwin)
        return windowpairs[blinkwin]
    end
    w = @js blinkwin window.innerWidth
    h = @js blinkwin window.innerHeight

    #loadjs!(blinkwin, joinpath("pkg", "Escher", "bower_components/webcomponentsjs/webcomponents.min.js"))
    body!(blinkwin, string("<script>", Patchwork.js_runtime(), "</script>"))
    importhtml!(blinkwin, joinpath("pkg", "Escher", "basics.html"))
    body!(blinkwin, "<signal-container signal-id='root'></signal-container>")

    stream = Signal(Signal, Signal(Tile, empty))
    win, stream = Base.@get! windowpairs blinkwin begin
      Escher.Window(blinkwin, dimension=(w*px, h*px)), stream
    end

    Reactive.foreach(win.assets) do asset
        path = Escher.resolve_asset(asset)
        importhtml!(blinkwin, path; async=true)
    end
    Blink.handle(win, "escher") do msg
        println("handling ", msg)
        handle_command(win, msg)
    end
    start_updates(flatten(stream, typ=Any), win, "root")
    win, stream
end

function send_command(window::Escher.Window{Blink.Window}, x)
    Blink.js_(window.output, :(window.Escher.recv($x)))
end

function launch(ui, w=Blink.Window())
    escher_win,stream = preparewindow(w) # This is memoized
    swap!(stream, ui)
    Reactive.preserve(stream)
    escher_win
end

function launch(f::Function, w=Blink.Window())
    escher_win,stream = preparewindow(w) # This is memoized
    launch(f(escher_win), w)
end

function launch(f::AbstractString, w=Blink.Window())
    launch(include(joinpath(pwd(), f)), w)
end
