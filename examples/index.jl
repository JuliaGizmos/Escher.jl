
jlfiles() =
    filter(x -> endswith(x, ".jl"), readdir())

showcode(f) =
    codemirror(readall(f))

loaded = Dict()
loadcode!(f, window, basepath) = begin
    path = joinpath(basepath, f)
    if haskey(loaded, path)
        return loaded[path]
    else
        ui = include(joinpath(pwd(), path))(window)
        loaded[path] = ui
        return ui
    end
end

wrapsignal(s::Signal) = s
wrapsignal(x) = Input{Tile}(x)

main(window) = begin
    push!(window.assets, "widgets")
    push!(window.assets, "layout2")
    push!(window.assets, "codemirror")

    basepath = pwd()
    files = ["markdown.jl",
             "compose.jl",
             "plotting.jl",
             "widgets.jl",
             "minesweeper.jl"]
    mnu = menu(map(item, files))
    cs = pages(map(showcode, files))

    examples = [wrapsignal(loadcode!(f, window, basepath))
                    for f in files]
    psᵗ = lift((es...) -> pages(es), examples...)

    lift(psᵗ) do ps
        m, p = wire(mnu, ps, :pageschannel, :selected)
        m, c = wire(m, cs, :codepageschannel, :selected)

        hbox(
            Escher.minwidth(10em, mnu),
            c |> size(40cent, 100vh), 
            hskip(1em),
            p
        ) |> packitems(axisstart)
    end |> Escher.teeprint
end
