export latex

immutable LaTeX <: Tile
    source::String
end

latex(x::String) = LaTeX(latex)
