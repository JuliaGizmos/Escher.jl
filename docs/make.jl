using Documenter, Escher, Literate
src = joinpath(@__DIR__, "src")
Literate.markdown(joinpath(src, "tutorial.jl"), src, codefence = "```julia" => "```")

makedocs(
    format = :html,
    sitename = "Escher",
    authors = "JuliaGizmos",
    pages = [
        "Introduction" => "index.md",
        "Observables" => "observables.md",
        "Widgets" => "widgets.md",
        "Layout" => "layout.md",
        "Deploying the web app" => "deploying.md",
        "Tutorial" => "tutorial.md",
    ]
)

deploydocs(
    repo = "github.com/JuliaGizmos/Escher.jl.git",
    target = "build",
    julia  = "0.6",
    osname = "linux",
    deps   = nothing,
    make   = nothing
)
