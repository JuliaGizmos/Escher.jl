export tabs, pages, menu, submenu, item, icon, iconbutton, toolbar
# Higher-order layouts: e.g. tabs, pages

abstract Selection <: Tile

for (fn, typ) in  [(:pages, :Pages), (:tabs, :Tabs), (:menu, :Menu)]
    @eval begin
        immutable $typ <: Selection
            tiles::AbstractArray
            multi::Bool
            selected::Any
        end
        $fn(tiles; selected=0, multi=false, name=:_tabs) =
            selectable($typ(tiles, multi, selected), name=name)
    end
end

render(ps::Pages) =
    render(ps.tiles, "core-pages") & [:selected=>ps.selected, :multi=>ps.multi]

render(tabs::Tabs) =
    Elem("paper-tabs",
        map(t -> Elem("paper-tab", render(t)), tabs.tiles),
        selected=tabs.selected, multi=tabs.multi)

render(m::Menu) =
    render(m.tiles, "core-menu") & [:selected=>m.selected, :multi=>m.multi]

immutable SubMenu <: Tile
    icon::String
    label::String
    tiles::AbstractArray
end
submenu(icon, label, tiles) = SubMenu(icon, label, tiles)
submenu(label, tiles) = SubMenu(icon, label, tiles)

render(m2::SubMenu) =
    render(m2.tiles, "core-submenu")

immutable Item <: Tile
    icon::String
    label::String
end

item(icon, label) = Item(icon, label)
item(label) = Item("", label)

render(i::Item) =
    Elem("core-item", icon=i.icon, label=i.label)

# Toolbar and Icons

@api toolbar => Toolbar <: Tile begin
    curry(tiles::AbstractArray)
end
render(t::Toolbar) =
    render(t.tiles, "core-toolbar")

@api icon => Icon <: Tile begin
    typedarg(icon::String="")
    kwarg(url::Bool=false)
end
render(i::Icon) =
    Elem("core-icon") & [(i.url ? :src : :icon) => i.icon]

@api iconbutton => IconButton <: Tile begin
    typedarg(icon::String="")
    kwarg(url::Bool=false)
end
render(i::IconButton) =
    Elem("paper-icon-button") & [(i.url ? :src : :icon) => i.icon]
