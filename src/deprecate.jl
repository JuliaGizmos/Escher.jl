import Base: @deprecate, broadcast
export sampler, sample

@deprecate broadcast(t::Tile) wrapbehavior(t)
@deprecate dropdownmenu(t::Tile, xs::AbstractArray) dropdownmenu(t, menu(xs))
@deprecate addinterpreter(x, y) intent(x, y)
@deprecate sample(x::Sampler, t) intent(x, t)
@deprecate plugsampler(s::Sampler, t::Tile) intent(s, t)
@deprecate constant(x, y) intent(constant(x), y)
@deprecate pairwith(x, y) intent(pairwith(x), y)
