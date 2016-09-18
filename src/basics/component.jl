
using FunctionalCollections

export Component,
       Action,
       noop,
       setfield,
       childaction,
       indexaction

"""
The abstract type for all Components
"""
abstract Component

"""
The view of a component
returns a UI with annotated intents
"""
function view
end

convert(::Type{Tile}, c::Component) = view(c)

"""
An action by/of a component - can be obtained from
the intent set in the view
"""
abstract Action <: Intent

"""
Given a `Component` and an `Action` transition to
a new `Component` after applying in the given `Action`
"""
function update
end

immutable NoOp <: Action
end

"""
No-op action
"""
const noop = NoOp()
update(c::Component, a::NoOp) = c

"""
Set a field. Update generates code for each component type and field.
Component must not have inner constructors for this to work
"""
immutable SetField{field, T} <: Action
    value::T
end
@compat (::Type{SetField{f}}){f,T}(x::T) = SetField{f, T}(x)

setfield(f::Symbol) = SetField{f}
setfield(f, x) = SetField{f}(x)

@generated function update{field}(c::Component, x::SetField{field})
    Expr(:call, c, [field === f ? :(x.value) : :(c.$f) for f in fieldnames(c)]...)
end

"""
Child action on a field
"""
immutable ChildAction{A<:Action} <: Action
    filed::Symbol
    action::A
end

childaction(f, action) = ChildAction(f, action)
childaction(f, idx, action) = childaction(f, indexaction(idx, action))

function update(c::Component, a::ChildAction)
    update(c, setfield(a.field, update(getfield(c, a.field), a.action)))
end

"""
Action on an index in a collection (vector / dict)
"""
immutable IndexAction{I,A<:Action} <: Action
    index::I
    action::A
end

function update(c::Union{Associative, AbstractArray}, a::IndexAction)
    assoc_(c, a.index, update(c[a.index], a))
end

assoc_(c::Union{PersistentVector, PersistentHashMap}, idx, x) = assoc(c, idx, x)
function assoc_(c, idx, x)
    c′ = copy(c)
    c′[idx] = x
    c′
end
