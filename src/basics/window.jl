export Window,
       include_asset

immutable Window
    alive::Input
    dimension::Input
    route::Input
    dir::String
    assets::Input
end

Window(;
    alive=true,
    dimension=(0px, 0px),
    route="",
    dir="ltr") =
    Window(Input{Bool}(alive), Input{Any}(dimension), Input{Any}(route), "ltr", Input("basics"))

resolve_asset(slug) = begin
    path = Pkg.dir("Escher", "assets", slug * ".html")
    if isfile(path)
        return "/assets/$slug.html"
    else
        error("Asset file $path doesn't exist")
    end
end
