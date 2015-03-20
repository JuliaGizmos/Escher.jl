
immutable ChanRecv <: Tile
    chan::Symbol
    tile::Tile
    attr::Symbol
end

immutable ChanSend <: Tile
    chan::Symbol
    tile::Tile
    attr::Symbol
end

send(chan, attr, tile::Tile) = ChanSend(chan, tile, attr)
recv(chan, attr, tile::Tile) = ChanSend(chan, tile, attr)
