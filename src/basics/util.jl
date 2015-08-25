using Colors

# Dict macro
macro d(xs...)
  if VERSION < v"0.4-"
    Expr(:dict, map(esc, xs)...)
  else
    :(Dict($(map(esc, xs)...)))
  end
end

convert(::Type{Color}, s::String) =
    parse(Colorant, s)

render_color(c) = string("#" * hex(c))

export intersperse

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
    arg(class::String, doc="Space separated classes.")
    curry(content::TileList, doc="A tile or a vector of tiles.")
    kwarg(
        forcewrap::Bool=false,
        doc="""If set to true, contents will be put in a containing tag and the
               classes are set on the container, even if there is only one tile.
               """
    )
    kwarg(wrap::Symbol=:div, doc="The tag to use for the container.")
end

maybestring(s::String, state) = s
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
       [prefix * name(part) * suffix => value for part in parts]

style(x) = @d(:style => x)

teeprint(x, fn=println) = begin
    fn(x)
    x
end
