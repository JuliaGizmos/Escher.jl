export intersperse

# Utility functions for Elem

boolattr(a, name) = a ? name : nothing

make_term(term, typ, parent) =
    [:(immutable $typ <: $parent end),
     :(const $(esc(term))  = $typ())]

macro terms(parent, terms)
    args = filter(x -> x.head != :line, terms.args)
    Expr(:block,
        reduce(vcat, [make_term(arg.args[1], arg.args[2], parent)
            for arg in args])...)
end

@doc """
Intersperse a value in between elements in a vector

Optionally you can tell it to enclose the result in the seperator element.

e.g.
```
intersperse(0, [1, 2, 3])
# => [1, 0, 2, 0, 3]

intersperse(0, [1, 2, 3], true)
# => [0, 1, 0, 2, 0, 3, 0]
```
""" ->
function intersperse(x, xs, enclose=false)
    if length(xs) > 1
        res = foldl((acc, nxt) -> vcat(acc, x, nxt),
                    Any[xs[1]], xs[2:end])
    else
        res = xs
    end
    enclose ? [x, res, x] : res
end
