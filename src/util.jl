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
