using Reactive

abstract SignalTile <: Tile

immutable AttrSignal{T} <: SignalTile
    tile::Tile
    name::String
    trigger::String
    val::T
end

# pipe the event to julia
immutable Pipe{T} <: SignalTile
    tile::Tile
    event::Symbol
end

abstract Transport

function setup_transport()
end

function setup_transport(signal, path, env)
end

#=

Example:

signal = getenv!(env, Input(0))
lift(sig1, sig2...) do s1, s2
    # Define view with input
    buttons = flow([
        p("What do I do now?"),
        button(:whatnext, "Previous", value=-1),
        button(:whatnext, "Next", value=1),
    ], Right())

    capture(signal, buttons, :whatnext, absorb=true)
end

=#
