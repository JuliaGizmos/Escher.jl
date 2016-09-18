using Colors

export intersperse,
       class,
       memoize

# Dict macro
macro d(xs...)
  if VERSION < v"0.4-"
    Expr(:dict, map(esc, xs)...)
  else
    :(Dict($(map(esc, xs)...)))
  end
end

convert(::Type{Color}, s::AbstractString) =
    parse(Colorant, s)

render_color(c) = string("#" * hex(c))


# Utility functions for Elem

boolattr(a) = a ? true : nothing # I know, this is insane

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
intersperse(x, xs, enclose=false) = begin
    if length(xs) > 1
        res = foldl((acc, nxt) -> vcat(acc, x, nxt),
                    Any[xs[1]], xs[2:end])
    else
        res = xs
    end
    enclose ? [x, res, x] : res
end

getproperty(el::Elem, prop, default) =
    hasproperties(el) ? get(properties(el), prop, default) : default


wrapmany(t::TileList, wrap, state) =
    length(t.tiles) == 1 ?
        render(t.tiles[1], state) :
        Elem(wrap, map(t -> render(t, state), t.tiles))

@api class => (Class <: Tile) begin
    doc("Add a HTML class.")
    arg(class::AbstractString, doc="Space separated classes.")
    curry(content::TileList, doc="A tile or a vector of tiles.")
    kwarg(
        forcewrap::Bool=false,
        doc="""If set to true, contents will be put in a containing tag and the
               classes are set on the container, even if there is only one tile.
               """
    )
    kwarg(wrap::Symbol=:div, doc="The tag to use for the container.")
end

maybestring(s::AbstractString, state) = s
maybestring(s::TileList, state) =
    length(s.tiles) == 1 ? maybestring(s.tiles[1], state) : render(s.tiles, state)
maybestring(s, state) = render(s, state)

addclasses(t, cs) =
    t & @d(:className => cs * " " * getproperty(t, :className, ""))

render(c::Class, state) =
    addclasses(c.forcewrap ? Elem(c.wrap, maybestring(c.content, state)) :
                           wrapmany(c.content, c.wrap, state),
               c.class)

@doc """
given a sentinal, vector of parts, prefix, suffix and a value,

if the vector of parts is referentially equal to the sentinal, then returns
    [prefix * suffix => value]
otherwise returns
    [prefix * name(part) * suffix => value for part in parts]

Can be used while rendering border/padding for different sides, or border
radius for different corners etc.
""" ->
mapparts(sentinal, parts, prefix, suffix, value) =
   parts === sentinal ?
       @d(prefix * suffix => value) :
       Dict(Pair[prefix * name(part) * suffix => value for part in parts])

style(x) = @d(:style => x)

teeprint(x, fn=println) = begin
    fn(x)
    x
end


# @doc """
# memoize anything's rendered output and state
# """ ->
#
# @api memoize => (Memoized<:Tile) begin
#     arg(tile::Any)
#     arg(store::WeakKeyDict=WeakKeyDict())
# end

deepmerge!(a::Associative, b::Associative) = begin
    for (k, v) in b
        @show k, v
        if isa(v, Associative) && haskey(a, k) && isa(a[k], Associative)
            @show k, "AAA"
            a[k] = deepmerge!(a[k], v)
        else
            a[k] = b[k]
        end
    end
    a
end

# Todo: allow specifying hash function,
# allow mirroring to JLD optionally
# render(m::Memoized, state) = begin
#     if haskey(m.store, m.tile)
#         deepmerge!(state, st) # This.
#         m.store[m.tile]
#     else
#         st = Dict("embedded_signals"=>Dict())
#         elem = render(convert(Tile, m.tile), st)
#         deepmerge!(state, st)
#       m.store[m.tile] = (elem, st)
#       elem
#   end
#end
