using Patchwork
using Reactive

output_path(file, dir) = begin
    out = abspath(joinpath(dir, file))
    return replace(out, r".jl$", ".html")
end

getvalue(ui::Signal) = value(ui)
getvalue(x) = x

mkoutputdir!(dir) = begin
    if isdir(dir)
        return
    elseif isfile(dir)
        error("$dir is not a directory")
    else
        mkdir(dir)
    end
end

escher_make(file, output_dir; single_file=false, assets_dir="pkg/Escher", copy_assets=false) = begin

    opath = output_path(file, output_dir)
    w = Window()
    Reactive.stop_event_loop()
    assets = foldp(push!, Any[], w.assets) # Accumulate assets
    Reactive.foreach(println, w.assets)
    uifn = include(joinpath(pwd(), file))
    ui = uifn(w)
    Reactive.run_till_now()

    mkoutputdir!(output_dir)

    asset_src  = Pkg.dir("Escher", "assets")
    asset_dest = joinpath(output_dir, assets_dir) |> abspath

    dir = dirname(asset_dest)
    if !isdir(dir)
        mkpath(dir)
    end
    if copy_assets
        cp(asset_src, asset_dest)
    else
        if !isfile(asset_dest) && !isdir(asset_dest)
            symlink(asset_src, asset_dest)
        end
    end

    state = Dict()
    state["embedded_signals"] = Dict()

    open(opath, "w") do io
        write(io, """<!doctype html>
        <html>
        <meta charset="utf-8">
        <head>
           <script> $(Patchwork.js_runtime()) </script>
           <script src="$assets_dir/bower_components/webcomponentsjs/webcomponents.min.js"></script>
        </head>

        $(

        join(map(x -> """<link rel="import" href="$(Escher.resolve_asset(x))">""",
                      vcat("basics", value(assets))), "\n")

        )

        <body>
        <signal-container id="root"></signal-container>
        </div>
        <script>
            new Patchwork.Node("root", $(replace(replace(Patchwork.jsonfmt(Escher.render(getvalue(ui), state)) |> json, "<", "\\<"), ">", "\\>")))
        </script>
        </body>
        </html>
        """)
    end
end
