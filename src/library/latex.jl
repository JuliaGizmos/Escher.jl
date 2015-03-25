export latex

immutable LaTeX <: Tile
    source::String
end

latex(x::String) = LaTeX(latex)

render(l::LaTeX) =
    Elem("ka-tex", source=l.source)
