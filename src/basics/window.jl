export Window,
       include_asset

immutable Window
    dimension::Input
    route::Input
    dir::String
    assets::Set
end

Window(;
    dimension=(0mm, 0mm),
    route="",
    dir="ltr") =
    Window(Input{Any}(dimension), Input{Any}(route), "ltr", Set{Any}())

include_asset(window, asset) =
    push!(window.assets, asset)
