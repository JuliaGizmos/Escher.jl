export Window,
       include_asset

immutable Window
    dimension::Input
    route::Input
    dir::String
    assets::Input
end

Window(;
    dimension=(0mm, 0mm),
    route="",
    dir="ltr") =
    Window(Input{Any}(dimension), Input{Any}(route), "ltr", Input("basics"))

function resolve_asset(slug)
    path = Pkg.dir("Canvas", "assets", slug * ".html")
    if isfile(path)
        return "/assets/$slug.html"
    else
        error("Asset file $path doesn't exist")
    end
end
