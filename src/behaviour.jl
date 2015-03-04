import Base: |>

export hasstate,
       clickable,
       leftbutton,
       rightbutton,
       scrollbutton

abstract Behaviour <: Tile

pipe(t::Behaviour, s::Input; absorb=true) =
    pipe(t, t.name, s, absorb=absorb)

(|>)(t::Behaviour, s::Input) = pipe(t, s)

immutable WithState{attr} <: Behaviour
    name::Symbol
    tile::Tile
    trigger::String
end

hasstate(tile::Tile; name=:_state, attr="value", trigger="change") =
    WithState{symbol(attr)}(name, tile, trigger)

# Sample a bunch of signals upon changes to another bunch of signals
# Returns a signal of dict of signal values
immutable SignalSampler <: Behaviour
    name::Symbol
    signals::AbstractArray
    triggers::AbstractArray
    tile::Tile
end

samplesignals(tosample, triggers, tile; name=:_sampler) =
    SignalSampler(name, tosample, triggers, tile)
samplesignals(tosample::Symbol, triggers::Symbol, tile; name=:_sampler) =
    SignalSampler(name, [tosample], [triggers], tile)
samplesignals(tosample::Symbol, triggers, tile; name=:_sampler) =
    SignalSampler(name, [tosample], triggers, tile)
samplesignals(tosample, triggers::Symbol, tile; name=:_sampler) =
    SignalSampler(name, tosample, [triggers], tile)

abstract MouseButton

@terms MouseButton begin
    leftbutton => LeftButton
    rightbutton => RightButton
    scrollbutton => ScrollButton
end

immutable Clickable <: Behaviour
    name::Symbol
    buttons::AbstractArray
    tile::Tile
end

convert(::Type{MouseButton}, x::Int) =
    try [leftbutton, rightbutton, scrollbutton][x]
    catch error("Invalid mouse button code: $x")
    end

clickable(t; name=:_clicks) =
    Clickable(name, [leftbutton], t)
clickable(buttons::AbstractArray, t; name=:_clicks) =
    Clickable(name, buttons, t)
clickable(buttons::AbstractArray{MouseButton}; name=:_clicks) =
    t -> clickable(buttons, t, name=name)

abstract MouseState

@terms MouseState begin
    mousedown => MouseDown
    mouseup => MouseUp
end

immutable Hoverable <: Behaviour
    name::Symbol
    tile::Tile
    get_coords::Bool
end

immutable Hover
    state::MouseState
    position::(Float64, Float64)
end

hoverable(t::Tile, get_coords=false; name=:_hover) = Hoverable(name, t, get_coords)

immutable Resizable <: Behaviour
    name::Symbol
    tile::Tile
    container::Tile
end

immutable Size
    proportions::(Float64, Float64)
end

resizable(tile, container; name=:_size) = Resizable(name, tile, container)

immutable Draggable <: Behaviour
    name::Symbol
    tile::Tile
    container::Tile
end

draggable(tile, container; name=:_drag) = Draggable(name, tile, container)

immutable Drag
    fraction::(Float64, Float64)
end

immutable Sortable <: Behaviour
    name::Symbol
    tile::AbstractArray
end

immutable PositionSwap
    swap::(Int, Int)
end

immutable Editable <: Behaviour
    name::Symbol
    tile::Tile
end

