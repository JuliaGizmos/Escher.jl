export Window,
       include_asset

immutable Window
    alive::Signal
    dimension::Signal
    route::Signal
    dir::AbstractString
    assets::Signal
end

Window(;
    alive=true,
    dimension=(0px, 0px),
    route="",
    dir="ltr") =
    Window(Signal(Bool, alive), Signal(Any, dimension), Signal(Any, route), "ltr", Signal(Any, "basics"))

resolve_asset(tup :: (@compat Tuple{AbstractString, AbstractString}), prefix ="pkg", joinfn=(x, y) -> x * "/" * y) = begin
    pkg = tup[1]
    slug = tup[2]
    path = Pkg.dir(pkg, "assets", slug * ".html")
    if isfile(path)
        return joinfn(prefix, joinfn( pkg, "$slug.html") )
    else
        error("Asset file $path doesn't exist")
    end
end

resolve_asset(slug::AbstractString) = resolve_asset(("Escher", slug))
