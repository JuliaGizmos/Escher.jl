using Color

getdoc(fn) =
    Escher.escher_meta[fn]

badge(x, bg="#f1f1f1") =
    fontsize(0.8em, x) |>
    pad([left, right], 0.25em) |>
    fillcolor(bg) |>
    roundcorner(0.25em)

#=
@doc """
format an argument metadata for use in function signature.

an optional argument is formatted as:

    [arg::T=value, ]

a curried argument is formatted as:

    «arg::T»

The Type will be of two colors. A green color means that
convert(::Type{T}, x) is called on the argument (x). While
a red color means that the argument must be of the specified type.

""" ->
=#
function argsig(arg)
    name = string(arg[:name])
    typ = string(arg[:type])
    typ_color = arg[:coerced] ? "#49796B" : "#A45A52" # Hooker green and redwood

    sig = [name, fontcolor("#aaa", "::"), fontcolor(typ_color, typ)]
    if haskey(arg, :default)
        sig = [sig, "=", fontcolor("#888", string(arg[:default]))]
        if !arg[:kwarg]
            sig = ["[ ", sig, " ]"]
        end
    end

    if arg[:curried]
        sig = ["« ", abbr("Curried", sig), " »"]
    end

    hbox(sig)
end

#= @doc """
Show the signature of a function.
""" -> =#
function signature(meta)
    fn = string(meta[:name])
    args   = map(argsig, filter(x -> !x[:kwarg], meta[:args]))
    kwargs = map(argsig, filter(x -> x[:kwarg], meta[:args]))

    sep = [",", hskip(0.5em)]
    sig = [ fontweight(bold, fn), "(", intersperse(sep, args)... ]
    if !isempty(kwargs)
        sig = [ sig, "; ", hskip(0.5em), intersperse(sep, kwargs) ]
    end
    sig = [ sig, ")" ]
    hbox(sig) |> wrap
end

rettype(typ) =
    typ.head == :curly ?
        string(typ.args[2]) :
        typ.head == :comparison ?
            abbr(string(typ.args[1]), string(typ.args[3])) :
            string(typ)

function argrow(arg)
    notes = Any[]
    if !arg[:coerced]
        push!(notes, badge(hbox("requires ", hskip(0.5em), code(string(arg[:type])))))
    end
    if arg[:kwarg]
        push!(notes, badge(abbr("Keyword argument", "kwarg")))
    end
    if arg[:curried]
        push!(notes, badge(abbr("Curried argument: if you leave this argument out, you will get a function which takes this argument", "curried")))
    end
    if haskey(arg, :default)
        push!(notes, badge("default=" * string(arg[:default])))
    end
    hbox(code(string(arg[:name])), intersperse(hskip(0.8em), notes, true)...) |>
         pad([top, bottom], 0.25em)
end

function argstable(args)
    vbox(map(argrow, args))
end


band(t, bg="#f1f1f1", fg="#000") =
      fontweight(500, t) |> fontcolor(fg) |> fontstyle(italic)

function showdoc(fn)
    d = getdoc(fn)
    docmd = d[:doc]

    vbox(
        vbox(signature(d),
             hbox(hskip(1em), "→", hskip(0.5em), rettype(d[:type])) |> fontcolor("#777")) |>
                fonttype(monospace),
        vbox(
             pad([left], 1em, docmd),
             band("Arguments"),
             argstable(d[:args]) |> pad([left, right], 1em) |> pad([top, bottom], 0.5em)
        ) |> pad([left], 1em)
    )
end

showdocs(fns) =
   vbox(intersperse([vskip(1em), 
        border([bottom], solid, 1px, color("#ddd"), empty),
        vskip(1em)],
        map(showdoc, fns)))
