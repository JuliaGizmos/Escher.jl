export tabs, pages, menu, submenu, item, select
# Higher-order layouts: e.g. tabs, pages

immutable Pages <: Tile
    tiles::TileList
end
pages(tiles) = Pages(tiles)

immutable Tabs <: Tile
    tiles::TileList
end
tabs(tiles) = Tabs(tiles)

immutable Menu <: Tile
    tiles::TileList
end
menu(tiles) = Menu(tiles)

immutable SubMenu <: Tile
    icon::String
    label::String
    tiles::TileList
end
submenu(icon, label, tiles) = SubMenu(icon, label, tiles)
submenu(label, tiles) = SubMenu(icon, label, tiles)

immutable Item <: Tile
    icon::String
    label::String
end

item(icon, label) = Item(icon, label)
item(label) = Item("", label)

immutable Selected{multi} <: Widget
    selected::Any
    tile::Tile
end

select(i, tile; name=:_selection) =
    hasstate(Selected(i, tile), attr=:selected, name=name)

