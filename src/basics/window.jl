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
    Window(Input{Bool}(alive), Input{Any}(dimension), Input{Any}(route), "ltr", Input{Any}("basics"))

resolve_asset(slug::String, prefix="/escher/assets", joinfn=(x, y) -> x * "/" * y) = begin
    path = Pkg.dir("Escher", "assets", slug * ".html")
    if isfile(path)
        return joinfn(prefix, "$slug.html")
    else
        error("Asset file $path doesn't exist")
    end
end

resolve_asset(tup :: (@compat Tuple{String, String}), prefix ="/pkg", joinfn=(x, y) -> x * "/" * y) = begin
    pkg = tup[1]
    slug = tup[2]
    path = Pkg.dir(pkg, "assets", slug * ".html")
    if isfile(path)
        return joinfn(prefix, joinfn( pkg, "$slug.html") )
    else
        error("Asset file $path doesn't exist")
    end
end
