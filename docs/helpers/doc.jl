using Colors

import Escher: @d

getdoc(fn) =
    Escher.escher_meta[fn]

const badge_themes = @d(
    :default => fillcolor("#e1f0e5"),
    :curried => fillcolor("#72b5a1"),
    :typedkwarg => fillcolor("#444A95"),
    :kwarg => fillcolor("#DC7F38"),
    :typedarg => fillcolor("#DCA938"),
)

badge(x, theme=:default) =
    fontsize(0.94em, x) |>
    pad([left, right], 0.4em) |>
    badge_themes[theme] |>
    pad(0.2em)

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
        sig = [sig, "=", fontcolor("#888", print_val(arg[:default]))]
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
    hbox(sig..., hskip(0.5em), "→", hskip(0.5em), rettype(meta[:type]) |> fontcolor("#777"))
end

rettype(typ) =
    typ.head == :curly ?
        string(typ.args[2]) :
        typ.head == :comparison ?
            abbr(string(typ.args[1]), string(typ.args[3])) :
            string(typ)

rettype(typ::Symbol) = string(typ)

print_val(x::Symbol) = ":$x"
print_val(x::Expr) = sprint(io -> print(io, x))
print_val(x) = sprint(io -> show(io, x))

function argrow(arg)
    notes = Any[]
    if !arg[:coerced]
        push!(notes, badge(hbox("type ", hskip(0.5em), code(string(arg[:type]))), :typedarg))
    end
    if arg[:kwarg]
        push!(notes, badge(abbr("Keyword argument", "kwarg"), :kwarg))
    end
    if arg[:curried]
        push!(notes, badge(abbr("Curried argument: if you leave this argument out, you will get a function which takes this argument", "curried"), :curried))
    end
    if haskey(arg, :default)
        push!(notes, badge("default=" * print_val(arg[:default])))
    end
    Any[code(string(arg[:name])), vskip(2em), hskip(1em), hbox(notes) |> wrap, hskip(1em), arg[:doc]]'
end

function argstable(args)
    table(
        Union{}[],
        reduce(vcat, map(argrow, args))
    )
end


band(t, bg="#f1f1f1", fg="#000") =
      fontweight(500, t) |> fontcolor(fg) |> fontstyle(italic)

import Escher:@api, render

@api table => (Table <: Tile) begin
    arg(headers::AbstractVector)
    arg(columns::AbstractMatrix)
end

render_cell(x, state) = Elem(:td, render(x, state))
render_row(xs, state) = Elem(:tr, map(x -> render_cell(x, state), xs))

render(t::Table, state) =
    Elem(:table, [
        isempty(t.headers) ? [] : Elem(:thead, Elem(:th, map(h -> render_cell(h, state), t.headers))),
        Elem(:tbody, map(row -> render_row(row, state), Any[sub(t.columns, i, :) for i in 1:size(t.columns, 1)]))
    ])

function showdoc(fn)
    d = getdoc(fn)
    docmd = d[:doc]

    vbox(
        signature(d) |> wrap |> fonttype(monospace),
        vbox(
             vskip(1em),
             pad([left], 1em, docmd),
             vskip(1em),
             band("Arguments"),
             argstable(d[:args]) |> pad([left, right], 1em) |> pad([top, bottom], 0.5em)
        ) |> pad([left], 1em)
    )
end

showdocs(fns) =
   vbox(intersperse([vskip(2em), 
        border([bottom], solid, 1Escher.px, colorant"#ddd", empty),
        vskip(2em)],
        map(showdoc, fns)))
