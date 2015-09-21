import Base.@deprecate
export sampler

@deprecate sample(s::Sampler, t::Tile) plugsampler(s, t)
@deprecate broadcast(t::Tile) wrapbehavior(t)
