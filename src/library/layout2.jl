export tabs,
       pages,
       menu,
       submenu,
       dropdown,
       dropdownmenu,
       item,
       icon,
       iconbutton,
       toolbar
# Higher-order layouts: e.g. tabs, pages

# Icons and icon button
@api icon => Icon <: Tile begin
    typedarg(icon::String="")
    kwarg(url::Bool=false)
end
render(i::Icon) =
    Elem("core-icon") & [(i.url ? :src : :icon) => i.icon]

@api iconbutton => IconButton <: Widget begin
    typedarg(icon::String="")
    kwarg(name::Symbol=:_iconbutton)
    kwarg(url::Bool=false)
end
render(i::IconButton) =
    Elem("paper-icon-button") & [(i.url ? :src : :icon) => i.icon]

watch(w::IconButton) =
    clickable(w, name=w.name)


abstract Selection <: Widget

@api pages => Pages <: Selection begin
    arg(tiles::TileList)
    kwarg(name::Symbol=:_pages)
    kwarg(selected::Integer=1)
end

render(ps::Pages) =
    Elem("core-pages", render(ps.tiles), selected=ps.selected-1)

@api tabs => Tabs <: Selection begin
    arg(tiles::TileList)
    kwarg(name::Symbol=:_tabs)
    kwarg(selected::Integer=1)
end

render(tabs::Tabs) =
    Elem("paper-tabs",
        map(t -> Elem("paper-tab", render(t)), tabs.tiles.tiles),
        selected=tabs.selected-1)

# Menus

@api menu => Menu <: Selection begin
    arg(tiles::TileList)
    kwarg(name::Symbol=:_menu)
    kwarg(selected::Integer=1)
end

render(m::Menu) =
    Elem("core-menu", render(m.tiles),
        selected=m.selected-1)

@api submenu => SubMenu <: Tile begin
    arg(icon::String="")
    arg(label::String)
    curry(tiles::TileList)
    kwarg(selected::Integer=1)
end

render(m2::SubMenu) =
    render(render(m2.tiles), "core-submenu")

# Toolbar

@api toolbar => Toolbar <: Tile begin
    arg(tiles::AbstractArray)
end

render(t::Toolbar) =
    render(t.tiles, "core-toolbar")

# Paper-item and dropdown

@api item => Item <: Widget begin
    arg(tile::Tile)
end

watch(i::Item) = clickable(i)

render(i::Item) =
    Elem("paper-item", render(i.tile), attributes=[:icon=>i.icon])

@api dropdown => Dropdown <: Widget begin
    arg(tile::Tile)
    kwarg(name::Symbol=:_dropdown)
    kwarg(halign::Side{Horizontal}=right)
    kwarg(valign::Side{Vertical}=top)
end
render(d::Dropdown) =
    Elem("paper-dropdown",
        render(d.tile),
        halign=lowercase(name(d.halign)),
        valign=lowercase(name(d.valign)))

@api dropdownmenu => DropdownMenu <: Selection begin
    arg(label::String="")
    arg(items::TileList)
    kwarg(halign::Side{Horizontal}=left)
    kwarg(valign::Side{Vertical}=top)
    kwarg(name::Symbol=:_dropdown_menu)
    kwarg(selected::Int=1)
    kwarg(disabled::Bool=false)
end

wrapitem(x::Item) = render(x)
wrapitem(x::String) = Elem("paper-item", x)
wrapitem(x) = Elem("paper-item", render(x))

function render(dm::DropdownMenu)
    # paper-dropdown-menu spec requires these classes
    m = render(menu(map(t -> wrapitem(t), dm.items.tiles))) & [:className => "menu"]
    d = render(dropdown(m, valign=dm.valign, halign=dm.halign)) & [:className => "dropdown"]

    Elem("paper-dropdown-menu",
        render(d),
        label=dm.label,
    )
end
watch(d::DropdownMenu) = hasstate(d, name=d.name)

# TODO:
#
# core-selector, single and multiple 
# ------------------------------
# 
