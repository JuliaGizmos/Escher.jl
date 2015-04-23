using Color

convert(::Type{ColorValue}, s::String) =
    color(s)

render_color(c) = string("#" * hex(c))

export intersperse

# Utility functions for Elem

boolattr(a, name) = a ? name : nothing

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

getproperty(el::Elem, prop, default) =
    hasproperties(el) ? get(properties(el), prop, default) : default


wrapmany(t::TileList, wrap) =
    length(t.tiles) == 1 ?
        render(t.tiles[1]) :
        render(t.tiles, wrap)

@api class => Class <: Tile begin
    arg(class::String)
    curry(content::TileList)
    kwarg(wrap::Symbol=:div)
    kwarg(forcewrap::Bool=false)
end

maybestring(s::String) = s
maybestring(s::TileList) =
    length(s.tiles) == 1 ? maybestring(s.tiles[1]) : render(s.tiles)
maybestring(s) = render(s)

addclasses(t, cs) =
    t & [:className => cs * " " * getproperty(t, :className, "")]

render(c::Class) =
    addclasses(c.forcewrap ? Elem(c.wrap, maybestring(c.content)) :
                           wrapmany(c.content, c.wrap),
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
       [prefix * suffix => value] :
       [prefix * name(part) * suffix => value for part in parts]

function teeprint(x, fn=println)
    fn(x)
    x
end

