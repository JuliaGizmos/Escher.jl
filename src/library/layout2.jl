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
@api icon => (Icon <: Tile) begin
    doc("An Icon.")
    typedarg(
        icon::String="",
        doc=md"""The name of the icon. Valid icons can be found in the
        [Polymer core-icon documentation](https://www.polymer-project.org/0.5/components/core-icons/demo.html)"""
    )
    kwarg(
        url::Bool=false,
        doc="Optionally you can specify a url to the png/svg of the icon."
    )
end
render(i::Icon, state) =
    Elem("core-icon") & @d((i.url ? :src : :icon) => i.icon)

@api iconbutton => (IconButton <: Widget) begin
    doc("A button with an inset icon.")
    typedarg(
        icon::String="",
        doc=md"""The name of the icon. Valid icons can be found in the
        [Polymer core-icon documentation](https://www.polymer-project.org/0.5/components/core-icons/demo.html)"""
    )
    kwarg(name::Symbol=:_iconbutton, doc="A name to identify the widget.")
    kwarg(
        url::Bool=false, 
        doc="Optionally you can specify a url to the png/svg of the icon."
    )
end
render(i::IconButton, state) =
    Elem("paper-icon-button") & @d((i.url ? :src : :icon) => i.icon)

broadcast(w::IconButton) =
    clickable(w, name=w.name)


abstract Selection <: Widget 

@api pages => (Pages <: Selection) begin #FIXME: Why is this a widget?
    doc("A set of pages. Only one selected page will be visible at any given time.")
    arg(tiles::TileList, doc="Pages.")
    kwarg(name::Symbol=:_pages, doc="A name to identify the widget.")
    kwarg(selected::Integer=1, doc="Index of the currently visible page.")
end

render(ps::Pages, state) =
    Elem("core-pages",
        map(t -> Elem("section", render(t, state)), ps.tiles.tiles),
        selected=ps.selected-1)

@api tabs => (Tabs <: Selection) begin
    doc("A horizontal tab bar.")
    arg(tiles::TileList, doc="The tabs.")
    kwarg(name::Symbol=:_tabs, doc="A name to identify the widget.")
    kwarg(selected::Integer=1, doc="Index of the currently selected tab.")
end

render(tabs::Tabs, state) =
    Elem("paper-tabs",
        map(t -> Elem("paper-tab", render(t, state)), tabs.tiles.tiles),
        selected=tabs.selected-1)

broadcast(t::Tabs) = selectable(t, name=t.name)

# Menus

@api menu => (Menu <: Selection) begin
    doc("A menu.")
    arg(
        tiles::TileList,
        doc="Menu items. Some of the items can also be sub-menus"
    )
    kwarg(name::Symbol=:_menu, doc="A name to identify the widget.")
    kwarg(selected::Integer=1, doc="Index of the currently selected menu item.")
end

render(m::Menu, state) =
    Elem("core-menu", render(m.tiles, state),
        selected=m.selected-1)

broadcast(m::Menu) = selectable(m, name=m.name)

@api submenu => (SubMenu <: Tile) begin
    doc("A submenu. Must be put inside a menu.")
    arg(icon::String="", doc="An optional icon.")
    arg(label::String, doc="The title of the sub menu.")
    curry(tiles::TileList, doc="Sub menu items.")
    kwarg(
        selected::Integer=1,
        doc="Index of the currently selected sub menu item."
    )
end

render(m2::SubMenu, state) =
    render(render(m2.tiles), "core-submenu", state)

# Toolbar

@api toolbar => (Toolbar <: Tile) begin
    doc("A toolbar.")
    arg(
        tiles::TileList,
        doc="""Contents of the toolbar. Will be laid out in an hbox.
               Use of icon button is recommended inside a toolbar."""
    )
end

render(t::Toolbar, state) =
    render(t.tiles, "core-toolbar", state)

# Paper-item and dropdown

@api item => (Item <: Widget) begin #FIXME: Is this only for dropdowns?
    doc("A menu item with an icon.")
    arg(tile::Tile, doc="The label.")
    kwarg(icon::String="", doc=md"An accompanying icon. See `icon` for more.")
end

broadcast(i::Item) = clickable(i)

render(i::Item, state) =
    Elem("paper-item", render(i.tile, state), attributes=@d(:icon=>i.icon))

@api dropdown => (Dropdown <: Widget) begin
    doc(md"A dropdown. For a dropdown menu use `dropdownmenu`")
    arg(tile::Tile, doc="Contents of the dropdown.")
    kwarg(name::Symbol=:_dropdown, doc="Name to identify the widget.")
    kwarg(
        halign::Side{Horizontal}=right,
        doc=md"""Horizontal alingment with respect to container.
             Valid values are `left` and `right`."""
    )
    kwarg(
        valign::Side{Vertical}=top,
        doc=md"""Vertical alingment with respect to container.
             Valid values are `top` and `bottom`."""
    )
end
render(d::Dropdown, state) =
    Elem("paper-dropdown",
        render(d.tile, state),
        halign=lowercase(name(d.halign)),
        valign=lowercase(name(d.valign)))

@api dropdownmenu => (DropdownMenu <: Selection) begin
    doc("A dropdown menu.")
    arg(label::String="", doc="Placeholder label.")
    arg(items::TileList, doc="The menu items.")
    kwarg(
        halign::Side{Horizontal}=left,
        doc=md"""Horizontal alingment with respect to container.
             Valid values are `left` and `right`."""
    )
    kwarg(
        valign::Side{Vertical}=top,
        doc=md"""Vertical alingment with respect to container.
             Valid values are `top` and `bottom`."""
    )
    kwarg(name::Symbol=:_dropdown_menu, doc="A name to identify the widget.")
    kwarg(selected::Int=1, doc="Index of the currently selected dropdown item.")
    kwarg(
        disabled::Bool=false,
        doc="If set to true, the dropdown menu is disabled."
    )
end

wrapitem(x::Item, state) = render(x, state)
wrapitem(x::String, state) = Elem("paper-item", x)
wrapitem(x, state) = Elem("paper-item", render(x, state))

render(dm::DropdownMenu, state) = begin
    # paper-dropdown-menu spec requires these classes
    m = render(menu(map(t -> wrapitem(t, state), dm.items.tiles)), state) & 
            @d(:className => "menu")
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
