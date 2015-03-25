using Docile
make_term(term, typ, parent) =
    [:(immutable $typ <: $parent end),
     :(const $(esc(term))  = $typ())]

@doc """
`@terms` allows you to create singleton types,
create instances and put them in constants.

E.g.

    abstract A
    @terms A begin
        x => X
        y => Y
        z => Z
    end

results in

    abstract A
    immutable X <: A end
    const x = X()

    immutable Y <: A end
    const y = Y()

    immutable Z <: A end
    const z = Z()

""" ->
macro terms(parent, terms)
    args = filter(x -> x.head != :line, terms.args)
    Expr(:block,
        reduce(vcat, [make_term(arg.args[1], arg.args[2], parent)
            for arg in args])...)
end

function argskwargs(exps)
    kwargs = filter(exp -> exp.args[1] in [:kwarg, :typedkwarg], exps)
    args = filter(exp -> !(exp.args[1] in [:kwarg, :typedkwarg]), exps)
    args, kwargs
end
function typebody(exp::Expr)
    if exp.head == :call
        if exp.args[2].head == :(::)
            return exp.args[2]
        elseif exp.args[2].head == :(kw)
            return exp.args[2].args[1]
        end
    end
    error("Invalid API definition")
end

function typebody(args::AbstractArray)
    map(typebody, args)
end

hasdefault(exp) = exp.args[2].head == :kw
argtype(exp) = exp.args[1]
function getvar(exp)
    decl = exp.args[2]
    hasdefault(exp) ?
        (argtype(exp) === :typedarg ? decl.args[1] : decl.args[1].args[1]) :
        (argtype(exp) === :typedarg ? decl : decl.args[1])
end
striptype(exp::Symbol) = exp
striptype(exp) = exp.head == :(::) ? exp.args[1] : exp

replaceparam(x::Symbol, params) = x
function replaceparam(x, params)
    if x.head === :(::)
        typ = get(params, x.args[2], x.args[2])
        return Expr(x.head, x.args[1], esc(typ))
    else
        return Expr(x.head, x.args[1], esc(typ))
    end
end

function states(arg, params)
    var = replaceparam(getvar(arg), params)

    if hasdefault(arg)
        val = arg.args[2].args[2]

        return Any[(false, var, striptype(var)), (false, nothing, esc(val))]
    else
        if argtype(arg) === :curry
            return Any[(false, var, striptype(var)), (true, striptype(var), striptype(var))]
        else
            return Any[(false, var, striptype(var))]
        end
    end
end

immutable ApiMethod
    args
    lambda_args
    constructor_args
end

function prependarg(state, method)
    curried, var, val = state
    lambda_args = method.lambda_args
    args = method.args
    constructor_args = method.constructor_args

    if curried
        lambda_args = vcat(var, lambda_args)
    else
        if var != nothing
            args = vcat(var, args)
        end
    end
    constructor_args = vcat(val, constructor_args)
    ApiMethod(args, lambda_args, constructor_args)
end

function teeprint(x, fn=println)
    fn(x)
    x
end

function makeapimethods(arglist, params)
    if length(arglist) == 0
        return Any[ApiMethod(Any[], Any[], Any[])]
    else
        this = arglist[1]
        rest = arglist[2:end]
        return [prependarg(state, method)
            for state in states(this, params), method in makeapimethods(rest, params)]
    end
end

function kwize(argdef)
    @assert argdef.args[1] in [:typedkwarg, :kwarg]

    if argdef.args[1] === :typedkwarg
        return argdef.args[2]
    else
        var = striptype(argdef.args[2].args[1])
        return Expr(:kw, var, argdef.args[2].args[2])
    end
end

function methodexpr(fn, typ, kws, kwnames, m)
    m = isempty(m.lambda_args) ?
        :(foo($(m.args...)) = $(esc(typ))($(m.constructor_args...), $(kwnames...))) :
        :(foo($(m.args...)) = ($(m.lambda_args...)) -> $(esc(typ))($(m.constructor_args...), $(kwnames...)))

    if !isempty(kws)
        m.args[1].args = vcat(fn, Expr(:parameters, kws...), m.args[1].args[2:end])
    end
    m.args[1].args[1] = esc(fn)
    m
end

typexpr(typ::Symbol) = typ
typexpr(typ) =
    typ.head === :comparison ?
        Expr(:(<:), typ.args[1], typ.args[3]) : typ

typename(typ::Symbol) = typ
typename(typ) =
    typ.head in [:comparison, :curly] ?
        typename(typ.args[1]) : typ

paramdict(typ::Symbol) = Dict()
paramdict(typ) =
    typ.head === :curly ?
    [param.args[1] => param.args[2] for param in typ.args[2:end]] :
        (typ.head === :(<:) ?
            paramdict(typ.args[1]) : Dict())
@doc """
`@api` is used to create new tile types and associated constructors

    @api border => Bordered{T <: Side} <: Tile begin
        arg(side::T)
        curry(tile::Tile)
        kwarg(color::ColorValue=color("black"))
    end
 
 Should result in:

     immutable Bordered{T <: Side} <: Tile
         tile::Tile
         color::ColorValue
     end
     border(side, tiles; color::ColorValue=color("black")) = Bordered(side, tiles, color)
     border(side; kwargs...) = tiles -> border(tiles; kwargs...)

""" -> 
macro api(names, body)

    fn, typ = names.args
    fields = body.args

    argdefs = filter(f -> f.head != :line, fields)

    typedef = Expr(:type, false, esc(typexpr(typ)),
        Expr(:block, typebody(argdefs)...))

    dict = paramdict(typexpr(typ))

    args, kwargs = argskwargs(argdefs)
    methoddefs = makeapimethods(args, dict)
    kws = map(kwize, kwargs)
    kwnames = map(x -> striptype(x.args[1]), kws)
    ms = map(m -> methodexpr(fn, typename(typ), kws, kwnames, m), methoddefs)

    Expr(:block, typedef, ms...)
end
