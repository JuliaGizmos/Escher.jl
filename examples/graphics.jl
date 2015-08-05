include("helpers/listing.jl")

function main(window)
    push!(window.assets, "widgets")
    push!(window.assets, "codemirror")
    push!(window.assets, "tex")

    vbox(
        title(3, "Graphics"),

        vskip(1em),
        h2("Vector Graphics"),
        md"Any [Compose.jl](http://composejl.org/) graphic can be readily used inside Escher.",
        vskip(1em),
        listing("""
        using Compose
        duck = compose(context(), 
          (context(), circle(0.45cx, 0.15cy, 0.02cx), fill("white")),
          (context(), circle(0.55cx, 0.15cy, 0.02cx), fill("white")),
          (context(), ellipse(0.5cx, 0.25cy, 0.04cx, 0.02cx), fill("orange")),
          (context(), circle(0.5cx,0.2cy,0.12cx)),
          (context(), circle(0.5cx, 0.6cy, 0.2cx)),
          fill("#eeeeee")
          )"""
        ),
        md"To resize a Compose graphic, you can use the `drawing` function.",
        listing("""
        drawing(4Compose.inch, 3Compose.inch, duck)"""),
             
        vskip(1em),
        h2("Plots"),
        md"Gadfly plots are rendered in Escher.",
        vskip(1em),
        listing("""
        using Gadfly
        randomwalk = plot(x=[1:100],y=cumsum(randn(100)), Geom.line)
        """),
 
        md"If you want to render the graphic as a png file instead of using the default `Patchwork` renderer, you can specify the backend in `drawing`.",
        listing("""
        drawing(PNG(4Compose.inch, 3Compose.inch), randomwalk)"""),

    ) |> pad(2em)
end
