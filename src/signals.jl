using Reactive

immutable InboundSignal <: Tile
    tile::Tile
    name::String
    signal::Input
end

pipe(t::Tile, signalname, s::Input) =
    InboundSignal(t, signalname, s)

setup_transport(x::Input) =
    error("Looks like there is no trasport set up for signals")

# Don't allow a signal to propagate outward
immutable StopSignal <: Tile
    tile::Tile
    name::String
end
stopsignal(tile::Tile, name::String) =
    StopSignal(tile, name)

# A low level type representing drawing a signal from a Patchwork level attribute
# This is ideally not part of user-facing API
immutable AttrSignal <: Tile
    tile::Tile
    name::String
    attr::String
    trigger::String
end

attrsignal(tile::Tile, name::String, attr="value", trigger="change") =
    AttrSignal(tile, name, attr, trigger)

attrsignal(tile::Tile, sig::Signal, attr="value", trigger="change", absorb=true) =
    pipe(attrsignal(tile, "val", attr, trigger), "val", sig) |>
    x -> absorb ? stopsignal(x, "val") : x

# Utility functions for transports
decodeJSON{T}(sig::Signal{T}, msg) = msg

import Base.Random: UUID, uuid4

const signal_to_id = Dict()
const id_to_signal = Dict()

function makeid(sig::Signal)
    if haskey(signal_to_id, sig)
        # todo ensure connection
        return signal_to_id[sig]
    else
        id = get!(() -> string(uuid4()), signal_to_id, sig)
        id_to_signal[id] = sig
        return id
    end
end
