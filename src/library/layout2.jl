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
render(i::Icon, state) =
    Elem("core-icon") & @d((i.url ? :src : :icon) => i.icon)

@api iconbutton => IconButton <: Widget begin
    typedarg(icon::String="")
    kwarg(name::Symbol=:_iconbutton)
    kwarg(url::Bool=false)
end
render(i::IconButton, state) =
    Elem("paper-icon-button") & @d((i.url ? :src : :icon) => i.icon)

broadcast(w::IconButton) =
    clickable(w, name=w.name)


abstract Selection <: Widget

@api pages => Pages <: Selection begin
    arg(tiles::TileList)
    kwarg(name::Symbol=:_pages)
    kwarg(selected::Integer=1)
end

render(ps::Pages, state) =
    Elem("core-pages",
        map(t -> Elem("section", render(t, state)), ps.tiles.tiles),
        selected=ps.selected-1)

@api tabs => Tabs <: Selection begin
    arg(tiles::TileList)
    kwarg(name::Symbol=:_tabs)
    kwarg(selected::Integer=1)
end

render(tabs::Tabs, state) =
    Elem("paper-tabs",
        map(t -> Elem("paper-tab", render(t, state)), tabs.tiles.tiles),
        selected=tabs.selected-1)

broadcast(t::Tabs) = selectable(t, name=t.name)

# Menus

@api menu => Menu <: Selection begin
    arg(tiles::TileList)
    kwarg(name::Symbol=:_menu)
    kwarg(selected::Integer=1)
end

render(m::Menu, state) =
    Elem("core-menu", render(m.tiles, state),
        selected=m.selected-1)

broadcast(m::Menu) = selectable(m, name=m.name)

@api submenu => SubMenu <: Tile begin
    arg(icon::String="")
    arg(label::String)
    curry(tiles::TileList)
    kwarg(selected::Integer=1)
end

render(m2::SubMenu, state) =
    render(render(m2.tiles), "core-submenu", state)

# Toolbar

@api toolbar => Toolbar <: Tile begin
    arg(tiles::AbstractArray)
end

render(t::Toolbar, state) =
    render(t.tiles, "core-toolbar", state)

# Paper-item and dropdown

@api item => Item <: Widget begin
    arg(tile::Tile)
    kwarg(icon::String="")
end

broadcast(i::Item) = clickable(i)

render(i::Item, state) =
    Elem("paper-item", render(i.tile, state), attributes=@d(:icon=>i.icon))

@api dropdown => Dropdown <: Widget begin
    arg(tile::Tile)
    kwarg(name::Symbol=:_dropdown)
    kwarg(halign::Side{Horizontal}=right)
    kwarg(valign::Side{Vertical}=top)
end
render(d::Dropdown, state) =
    Elem("paper-dropdown",
        render(d.tile, state),
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

wrapitem(x::Item, state) = render(x, state)
wrapitem(x::String, state) = Elem("paper-item", x)
wrapitem(x, state) = Elem("paper-item", render(x, state))

render(dm::DropdownMenu, state) = begin
    # paper-dropdown-menu spec requires these classes
    m = render(menu(map(t -> wrapitem(t, state), dm.items.tiles)), state) & @d(:className => "menu")
    d = Elem("paper-dropdown", m) & @d(:className => "dropdown")

    Elem("paper-dropdown-menu",
        render(d, state),
        label=dm.label,
    )
end
broadcast(d::DropdownMenu) = selectable(d, name=d.name, elem=".menu")

# TODO:
#
# core-selector, single and multiple 
# ------------------------------
# 
