
make_term(term, typ, parent) =
    [:(immutable $typ <: $parent end),
     :(const $(esc(term))  = $typ())]

@doc """
`@terms` allows you to create singleton types,
create instances as constants.

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

@doc """
separate out arguments and keyword arguments in a vector of field definitions
""" ->
argskwargs(exps) = begin
    kwargs = filter(exp -> exp.args[1] in [:kwarg, :typedkwarg], exps)
    args = filter(exp -> !(exp.args[1] in [:kwarg, :typedkwarg]), exps)
    args, kwargs
end

@doc """
Convert a field definition into a field definition inside a type declaration
    e.g. arg(x::Number=42)
will just become
    x::Number
""" ->
typebody(exp::Expr) = begin
    if exp.head == :call
        if exp.args[2].head == :(::)
            return exp.args[2]
        elseif exp.args[2].head == :(kw)
            return exp.args[2].args[1]
        end
    end
    error("Invalid API definition")
end

@doc """
Convert a vector of field definition into a vector of field definition inside a type declaration
    e.g. [:(arg(x::Number=42)), :(typedarg(y::AbstractString="a")), :(kwarg(z::Complex=1+im))]
will just become
    [:(x::Number), :(y::AbstractString), :(z::Complex)]

""" ->
typebody(args::AbstractArray) = begin
    map(typebody, args)
end

@doc """
does this field definition contain a default value?
""" ->
hasdefault(exp) = exp.args[2].head == :kw

@doc """
What kind of a field is it?

returns on of :arg, :typedarg, :kwarg, :typedkwarg
""" ->
argtype(exp) = exp.args[1]

@doc """
given a field definition, returns the name[::Type] to be used in method arguments
""" ->
getvar(exp) = begin
    decl = exp.args[2]
    hasdefault(exp) ?
        (argtype(exp) === :typedarg ? decl.args[1] : decl.args[1].args[1]) :
        (argtype(exp) === :typedarg ? decl : decl.args[1])
end

@doc """
If given a (::), remove the type annotation and just return the name of the variable
""" ->
striptype(exp::Symbol) = exp
striptype(exp) = exp.head == :(::) ? exp.args[1] : exp

@doc """
Given an expression possibly of the form x::T
and a dictionary of type parameters e.g. Dict(:T => :Number)

returns an expression of the form x::Number
""" ->
replaceparam(x::Symbol, params) = x
replaceparam(x, params) = begin
    if x.head === :(::)
        typ = get(params, x.args[2], x.args[2])
        return Expr(x.head, x.args[1], esc(typ))
    else
        return Expr(x.head, x.args[1], esc(typ))
    end
end

@doc """
Given an argument definition and a dictionary of type parameters,
returns different states the arguments can be in in a method definition

the returned value is a Vector of 3-tuples with the following elements
1. Bool: Should the argument be curried?
2. Variable name (or a variable name with a type in case of typedarg)
3. value to use while constructing the underlying type.
""" ->
states(arg, params) = begin
    var = replaceparam(getvar(arg), params)

    if hasdefault(arg)
        val = arg.args[2].args[2]

        return Any[(false, var, striptype(var)), (false, nothing, esc(val))]
    else
        if argtype(arg) === :curry
            return Any[(false, striptype(var), striptype(var)),
                       (true, striptype(var), striptype(var))]
        else
            return Any[(false, var, striptype(var))]
        end
    end
end

@doc """
Internal representation of the method definition sans kwargs
""" ->
immutable ApiMethod
    args
    lambda_args
    constructor_args
end

@doc """
used by makeapimethods to prepend an argument to a method object
""" ->

prependarg(state, method) = begin
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

@doc """
Given a list of field definitions (see @api) and a dictionary of type parameters
(e.g. T <: Number would have an entry :T => :Number in the dict),
returns a list of ApiMethod objects representing the various methods emerging from
the API definition. Keyword arguments are to be added in when actually creating the
method definitions.
""" ->
makeapimethods(arglist, params) = begin
    if length(arglist) == 0
        return Any[ApiMethod(Any[], Any[], Any[])]
    else
        this = arglist[1]
        rest = arglist[2:end]
        return [prependarg(state, method)
            for state in states(this, params), method in makeapimethods(rest, params)]
    end
end

@doc """
Takes a field defintioin of the form

    typedkwarg(x::T=default)
or
    kwarg(x::T=default)

And returns a kw expression of the form

    x::T=default
or
    x=default

respectively. The returned expression is of the form Expr(:kw, key, value)

""" ->
kwize(argdef) = begin
    @assert argdef.args[1] in [:typedkwarg, :kwarg]

    if argdef.args[1] === :typedkwarg
        return argdef.args[2]
    else
        var = striptype(argdef.args[2].args[1])
        return Expr(:kw, var, argdef.args[2].args[2])
    end
end

methodexpr(fn, typ, kws, kwnames, m) = begin
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
    Dict(Pair[param.args[1] => param.args[2] for param in typ.args[2:end]]) :
        (typ.head === :(<:) ?
            paramdict(typ.args[1]) : Dict())

@doc """
From a field definition, generate metadata for documenting the field
""" ->
argdoc(arg, params, iskwarg=false) = begin
    name, typ = typebody(arg).args
    kws = filter(x-> isa(x, Expr) && x.head === :kw, arg.args[2:end])
    docstr = get(Any[get(kw.args, 2, "") for kw in
                filter(x->get(x.args, 1, :x) == :doc, kws)], 1, "")

    dict = Dict()
    dict[:name] = name
    dict[:type] = get(params, typ, typ)
    dict[:coerced] = true
    dict[:curried] = false
    dict[:kwarg] = iskwarg

    if hasdefault(arg)
        dict[:default] = arg.args[2].args[2]
    else
        if argtype(arg) === :curry
            dict[:curried] = true
        elseif argtype(arg) in [:typedarg, :typedkwarg]
            dict[:coerced] = false
        end
    end

    :(merge($dict, (@compat Dict(:doc=>$docstr))))
end

@doc """
Given field definitions (both args and kwargs),
return the documentation object for an API
""" ->
argdocs(args, kwargs, params) =
    Expr(:vcat, map(arg -> argdoc(arg, params), args)...,
                map(kwarg -> argdoc(kwarg, params, true), kwargs)...)

const escher_meta = Dict()

@doc """
`@api` is used to create new tile types and associated constructors

    @api border => (Bordered{T <: Side} <: Tile) begin
        arg(side::T)
        curry(tile::Tile)
        kwarg(color::Color=colorant"black")
    end

 Should result in:

     immutable Bordered{T <: Side} <: Tile
         tile::Tile
         color::Color
     end
     border(side, tiles; color::Color=colorant"black") = Bordered(side, tiles, color)
     border(side; kwargs...) = tiles -> border(tiles; kwargs...)

""" ->
macro api(names, body)

    fn, typ = names.args
    fields = body.args

    nolines = filter(f -> f.head != :line, fields)
    argdefs = filter(f -> f.args[1] != :doc, nolines)
    docs = filter(f -> f.args[1] == :doc, nolines)

    typedef = Expr(:type, false, typexpr(typ),
        Expr(:block, typebody(argdefs)...)) |> esc

    dict = paramdict(typexpr(typ))

    args, kwargs = argskwargs(argdefs)

    methoddefs = makeapimethods(args, dict)
    kws = map(kwize, kwargs)
    kwnames = map(x -> striptype(x.args[1]), kws)
    ms = map(m -> methodexpr(fn, typename(typ), kws, kwnames, m), methoddefs)

    docstr = get(docs, 1, :(doc(""))).args[2]
    doc = :(@compat Dict(
        :doc=> $docstr,
        :name=>$fn,
        :type=>$(Expr(:quote, typ)),
        :args=>$(argdocs(args, kwargs, dict))
    ))

    # save metadata
    setdoc = :(escher_meta[$(esc(fn))] = $(esc(doc)))
    Expr(:block, typedef, ms..., setdoc)
end

macro apidoc(names, body)

    fn, typ = names.args
    fields = body.args

    nolines = filter(f -> f.head != :line, fields)
    argdefs = filter(f -> f.args[1] != :doc, nolines)
    docs = filter(f -> f.args[1] == :doc, nolines)

    typedef = Expr(:type, false, typexpr(typ),
        Expr(:block, typebody(argdefs)...)) |> esc

    dict = paramdict(typexpr(typ))

    args, kwargs = argskwargs(argdefs)

    methoddefs = makeapimethods(args, dict)
    kws = map(kwize, kwargs)
    kwnames = map(x -> striptype(x.args[1]), kws)

    docstr = get(docs, 1, :(doc(""))).args[2]
    doc = :(@compat Dict(
        :doc=> $docstr,
        :name=>$fn,
        :type=>$(Expr(:quote, typ)),
        :args=>$(argdocs(args, kwargs, dict))
    ))

    # save metadata
    :(escher_meta[$(esc(fn))] = $(esc(doc)))
end
