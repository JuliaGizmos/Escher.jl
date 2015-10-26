
fig(x) = pad(1em, x)

fileExt = "jl"

drawerMenu = vbox(
h1(link("index.$fileExt","Escher")),
h3("API Reference"),
link("layout-api.$fileExt","Layout API") |> list,
link("layout2-api.$fileExt","Higher Order Layouts API") |> list,
link("embellishment-api.$fileExt","Embellishment API") |> list,
link("typography-api.$fileExt","Typography API") |> list,
link("content-api.$fileExt","Content API") |> list,
link("widgets-api.$fileExt","Widgets API") |> list,
link("behavior-api.$fileExt","Behavior API") |> list,
link("signal-api.$fileExt","Signal API") |> list,
link("slideshow-api.$fileExt","Slideshow API") |> list,
link("tex-api.$fileExt","TeX API") |> list,
link("util-api.$fileExt","Util API") |> list,
h3("WIP: User Guides"),
link("layout.$fileExt","Layout Guide") |> list,
link("theme.$fileExt","Theme") |> list,
link("reactive.$fileExt","Reactive programming Guide") |> list,
)

docpage(tile; padding=1em, widthcap=920px) =
    hbox(pad(padding, tile) |> maxwidth(widthcap), flex()) |> drawer(drawerMenu)
