export cycle

immutable ClassSet
    classes::Set{String}
end

ClassSet(c) = ClassSet([string(c)])
ClassSet(c::ClassSet) = copy(c)
ClassSet(c::String) = ClassSet(split(c, r"\s+"))

function addclass(el::Elem, cls)
    props = attributes(el)
    if haskey(props, :className)
        cls = ClassSet(props[:className])
        push!(cls.classes, cls)
        el & [:className => cls]
    else
        el & [:className => ClassSet(cls)]
    end
end

immutable CyclingIterator{T} <: AbstractVector{T}
    array::AbstractVector{T}
end

cycle(itr) = CyclingIterator(itr)
function take_n(n::Int, c::CyclingIterator)
    l = length(c.array)
    if l >= n
        return c.array[1:n]
    else
        return [c.array, take_n(n-l, c)]
    end
end

# Utility functions for Elem

boolattr(x::Union(Symbol, String)) = [:attributes => [x => x]]
boolattr(xs::AbstractVector) =
    [:attributes => [x => x for x in xs]]

genid(prefix) = prefix * string(gensym(), "#", "")

const counters = Dict()
function nexttag(prefix)
    idx = get(counters, prefix, 1)
    counters[prefix] = idx + 1
    symbol(string(prefix, idx))
end
