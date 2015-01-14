using Reactive

export statesignal, stoppropagation, pipe

immutable InboundSignal <: Tile
    tile::Tile
    name::Symbol
    signal::Input
end

pipe(t::Tile, signalname, s::Input) =
    InboundSignal(t, signalname, s)

setup_transport(x::Input) =
    error("Looks like there is no trasport set up for signals")

# Don't allow a signal to propagate outward
immutable StopPropagation <: Tile
    tile::Tile
    name::Symbol
end
stoppropagation(tile::Tile, name::Symbol) =
    StopPropagation(tile, name)

# A low level type representing drawing a signal from a Patchwork level attribute
# This is ideally not part of user-facing API
immutable StateSignal <: Tile
    tile::Tile
    name::Symbol
    attr::String
    trigger::String
end

statesignal(tile::Tile, name; attr="value", trigger="change") =
    StateSignal(tile, name, attr, trigger)

statesignal(w::Tile, x::Input; tag=:val, attr="value", trigger="change", absorb=true) =
    pipe(statesignal(w, tag, attr=attr, trigger=trigger), tag, x) |>
       (x -> absorb ? stoppropagation(x, tag) : x)

# Utility functions for transports
decodeJSON(sig::Input, val) = val

istruthy(::Nothing) = false
istruthy(b::Bool) = b
istruthy(::None) = false
istruthy(x) = !isempty(x)

decodeJSON(sig::Input{Bool}, val) = istruthy(val)

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
