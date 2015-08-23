export tabs,
       pages,
       menu,
       submenu,
       dropdown,
       dropdownmenu,
       menuitem,
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
        [Polymer iron-icon documentation](https://www.polymer-project.org/0.5/components/iron-icons/demo.html)"""
    )
    kwarg(
        url::String="",
        doc="Optionally you can specify a url to the png/svg of the icon. icon field will be ignored if url is non-empty."
    )
end
render(i::Icon, state) = begin
    if i.url == ""
        Elem("iron-icon", attributes=@d(:icon => i.icon))
    else
        Elem("iron-icon", attributes=@d(:src => i.url))
    end
end

@api iconbutton => (IconButton <: Widget) begin
    doc("A button with an inset icon.")
    typedarg(
        icon::String="",
        doc=md"""The name of the icon. Valid icons can be found in the
        [Polymer iron-icon documentation](https://www.polymer-project.org/0.5/components/iron-icons/demo.html)"""
    )
    kwarg(name::Symbol=:_iconbutton, doc="A name to identify the widget.")
    kwarg(
        url::String="",
        doc="Optionally you can specify a url to the png/svg of the icon. icon field will be ignored if url is non-empty."
    )
end
render(i::IconButton, state) = begin
    if i.url == ""
        Elem("paper-icon-button", attributes=@d(:icon => i.icon))
    else
        Elem("paper-icon-button", attributes=@d(:src => i.url))
    end
end

wrapbehavior(w::IconButton) =
    clickable(w, name=w.name)


abstract Selection <: Widget 

@api pages => (Pages <: Selection) begin #FIXME: Why is this a widget?
    doc("A set of pages. Only one selected page will be visible at any given time.")
    arg(pages::TileList, doc="Pages.")
    kwarg(name::Symbol=:_pages, doc="A name to identify the widget.")
    kwarg(selected::Integer=1, doc="Index of the currently visible page.")
end

render(ps::Pages, state) =
    Elem("iron-pages",
        map(t -> Elem("section", render(t, state)), ps.pages.tiles),
        attributes = @d(:selected=>ps.selected-1))

@api tabs => (Tabs <: Selection) begin
    doc("A horizontal tab bar.")
    arg(tabs::TileList, doc="The tabs.")
    kwarg(name::Symbol=:_tabs, doc="A name to identify the widget.")
    kwarg(selected::Integer=1, doc="Index of the currently selected tab.")
end

render(tabs::Tabs, state) =
    Elem("paper-tabs",
        map(t -> Elem("paper-tab", render(t, state)), tabs.tabs.tiles),
        attributes = @d(:selected=>tabs.selected-1))

wrapbehavior(t::Tabs) = selectable(t, name=t.name)

# Menus

@api menu => (Menu <: Selection) begin
    doc("A menu.")
    arg(
        items::TileList,
        doc="Menu items. Some of the items can also be sub-menus"
    )
    kwarg(
        multi::Bool=false,
        doc="Can multiple items be selected? If set, output signal contains a vector of indices"
    )
    kwarg(name::Symbol=:_menu, doc="A name to identify the widget.")
    kwarg(selected::Integer=1, doc="Index of the currently selected menu item.")
end

render(m::Menu, state) =
    Elem("paper-menu",
        map(x -> render(wrapitem(x), state), m.items.tiles),
        attributes = @d(:selected=>m.selected-1, :multi=>boolattr(m.multi)))

wrapbehavior(m::Menu) = selectable(m, name=m.name, multi=m.multi)

@api submenu => (SubMenu <: Selection) begin
    doc("A submenu. Must be put inside a menu.")
    arg(label::Tile, doc="The title of the sub menu.")
    curry(items::TileList, doc="Sub menu items.")
    kwarg(
        multi::Bool=false,
        doc="Can multiple items be selected? If set, output signal contains a vector of indices"
    )
    kwarg(
        selected::Integer=1,
        doc="Index of the currently selected sub menu item."
    )
    kwarg(name::Symbol=:_submenu, doc="A name to identify the widget.")
end

render(m2::SubMenu, state) =
    Elem("paper-submenu",
        [addclasses(render(wrapitem(m2.label), state), "menu-trigger"),
         addclasses(render(menu(m2.items, multi=m2.multi,
                                selected=m2.selected, name=m2.name), state), "menu-content")])

wrapbehavior(m::SubMenu) = selectable(m, name=m.name, multi=m.multi)

@api menuitem => (MenuItem <: Tile) begin
    arg(tile::Tile)
    kwarg(disabled::Bool=false)
end

render(i::MenuItem, state) =
    Elem("paper-item", render(i.tile, state),
        attributes=@d(:disabled=>boolattr(i.disabled)))

wrapitem(x::MenuItem) = x
wrapitem(x::SubMenu) = x
wrapitem(x) = menuitem(x)

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
    render(t.tiles, "paper-toolbar", state)


# @api dropdown => (Dropdown <: Widget) begin
#     doc(md"A dropdown. For a dropdown menu use `dropdownmenu`")
#     arg(tile::Tile, doc="Contents of the dropdown.")
#     kwarg(name::Symbol=:_dropdown, doc="Name to identify the widget.")
#     kwarg(
#         halign::Side{Horizontal}=right,
#         doc=md"""Horizontal alingment with respect to container.
#              Valid values are `left` and `right`."""
#     )
#     kwarg(
#         valign::Side{Vertical}=top,
#         doc=md"""Vertical alingment with respect to container.
#              Valid values are `top` and `bottom`."""
#     )
# end
# render(d::Dropdown, state) =
#     Elem("iron-dropdown",
#         render(d.tile, state),
#         attributes=@d(
#             "horizontal-align"=>lowercase(name(d.halign)),
#             "vertical-align"=>lowercase(name(d.valign))))

@api dropdownmenu => (DropdownMenu <: Selection) begin
    doc("A dropdown menu.")
    arg(label::String="", doc="The label.")
    arg(menu::Tile, doc="The menu (any Selection widget).")
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
    kwarg(
        name::Symbol=:_dropdown_menu,
        doc="A name to identify the widget."
    )
    kwarg(
        floatinglabel::Bool=true,
        doc="Whether to show a floating label at the top."
    )
    kwarg(
        opened::Bool=false,
        doc="If set to true dropdown menu will be opened."
    )
    kwarg(
        disabled::Bool=false,
        doc="If set to true, the dropdown menu is disabled."
    )
end

render(dm::DropdownMenu, state) = begin
    # paper-dropdown-menu spec requires these classes

    Elem("paper-dropdown-menu",
        addclasses(render(dm.menu, state), "dropdown-content"),
        attributes = @d(
            "label"=>dm.label,
            "opened"=>boolattr(dm.opened),
            "no-label-float"=>boolattr(!dm.floatinglabel),
        )
    )
end
wrapbehavior(d::DropdownMenu) = selectable(d, name=d.name, selector=".dropdown-content")

