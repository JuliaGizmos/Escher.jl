
import Base: $

export stoppropagation,
       decoder,
       constant,
       pairwith,
       pairwithindex,
       subscribe,
       samplesignals


# First line of decoding.

decodeJSON(x) = x

function decodeJSON(ctr, x)
    # ctr is the constructor
    if typ == "Tuple"
        tuple(x.data...)
    else
        x
    end
end

decodeJSON(x::Dict) =
    haskey(x, "_type") ?
        decodeJSON(x["_type"], x) : x

@doc """
A Behavior is a tile that denotes that it can
broadcast some signal
""" ->
abstract Behavior <: Tile

name(b::Behavior) = b.name

# Second line of decoding - usually in the business logic

abstract Decoder

@api decoder => WithDecoder <: Behavior begin
    arg(decoder::Decoder)
    curry(tile::Behavior)
end
name(d::WithDecoder) = name(d.tile)

render(d::WithDecoder) =
    render(d.tile)

# Don't change the message
immutable Id <: Decoder
end
const identity = Id()

decode(dec::Id, x) = x

# Pair with a constant
immutable ConstPair <: Decoder
    value::Any
end

decode(dec::ConstPair, x) = (x, dec.value)

pairwith(x, tile::Tile) = decoder(ConstPair(x), tile)
pairwith(x) = decoder(ConstPair(x))
pairwith(x::AbstractArray, tiles::AbstractArray) = map(pairwith, x, tiles)
pairwith(x, tiles::AbstractArray) = map(pairwith(x))

pairwithindex(tiles::AbstractVector) =
    [pairwith(i, v)
        for (i, v) in enumerate(tiles)]

pairwithindex(tiles::AbstractMatrix) =
    [pairwith((i, j), tiles[i, j])
        for i=1:size(tiles, 1), j=1:size(tiles, 2)]

# Instead of the signal value, use a constant
immutable Const <: Decoder
    value::Any
end

decode(dec::Const, _) = dec.value

constant(x, tile::Tile) = decoder(Const(x), tile)
constant(x) = decoder(Const(x))
constant(xs::AbstractArray, tiles::AbstractArray) = map(constant, xs, tiles)
constant(x, tiles::AbstractArray) = map(constant(x), tiles)

# Apply a function
immutable DecoderFn <: Decoder
    f::Function
end
decoder(f::Function, tile::Tile) = decoder(DecoderFn(f), tile)
decode(dec::DecoderFn, x) = dec.f(x)

# Apply a function with some constant partial args
# For efficiency, the function must be defined outside
# of any signal functions. i.e. no point creating
# ad-hoc functions

immutable DecoderPartialFn <: Decoder
    f::Function
    args::Tuple
end
partial(f::Function, args::Tuple, tile) =
    decoder(DecoderPartialFn(f, args), tile)

decode(dec::DecoderPartialFn, x) = dec.f(dec.args..., x)


# Send a signal update to the Julia side
immutable Subscription <: Tile
    tile::Tile
    name::Symbol # Name of the signal update on the front-end
    receiver::(Decoder, Input)
end

subscribe(t::Tile, name, s; absorb=true) =
    Subscription(t, name, s) |>
       (x -> absorb ? stoppropagation(x, name) : x)

subscribe(t::Behavior, s::Input; absorb=true) =
    subscribe(t, name(t), (identity, s), absorb=absorb)
subscribe(t::Behavior, s::(Decoder, Input); absorb=true) =
    subscribe(t, name(t), s, absorb=absorb)

render(sig::Subscription) =
    render(sig.tile) <<
        Elem("signal-transport",
            name=sig.name, signalId=setup_transport(sig.receiver))


setup_transport(x) =
    error("Looks like there is no trasport set up")

import Base.Random: UUID, uuid4

const signal_to_id = Dict()
const id_to_signal = Dict()

function makeid(sig)
    if haskey(signal_to_id, sig)
        # todo ensure connection
        return signal_to_id[sig]
    else
        id = get!(() -> string(uuid4()), signal_to_id, sig)
        id_to_signal[id] = sig
        return id
    end
end

function fromid(id)
    id_to_signal[id]
end

# Don't allow a signal to propagate outward
immutable StopPropagation <: Tile
    tile::Tile
    name::Symbol
end

@doc """
Stop a UI signal from propagating further.
""" ->
stoppropagation(tile::Tile, name::Symbol) =
    StopPropagation(tile, name)

render(tile::StopPropagation) =
    render(tile.tile) <<
        Elem("stop-propagation",
            name=tile.name)


(>>>)(t::Behavior, s::Input) = subscribe(t, (identity, s))

# TODO: Use a different operator with lesser precedence than >>>
(>>>)(t::Behavior, f::Function) = decoder(f, t)
(>>>)(t::WithDecoder, s::Input) = subscribe(t, (t.decoder, s))

