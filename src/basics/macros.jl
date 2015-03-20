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

function states(arg)
    var = getvar(arg)

    if hasdefault(arg)
        val = arg.args[2].args[2]

        return [(false, var, var), (false, nothing, val)]
    else
        if argtype(arg) === : curry
            return [(false, var, var), (true, striptype(var), var)]
        else
            return [(false, var, var)]
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

function makeapimethods(arglist)
    if length(arglist) == 0
        return Any[ApiMethod(Any[], Any[], Any[])]
    else
        this = arglist[1]
        rest = arglist[2:end]
        return [prependarg(state, method)
            for state in states(this), method in makeapimethods(rest)]
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

    typedef = :(immutable $typ end)
    body = typebody(argdefs)
    typedef.args[3].args = body

    args, kwargs = argskwargs(argdefs)
    methoddefs = makeapimethods(args)
    kws = map(kwize, kwargs)
    kwnames = map(x -> striptype(x.args[1]), kws)
    ms = map(m -> methodexpr(fn, typ, kws, kwnames, m), methoddefs)

    Expr(:block, typedef, ms...)
end
