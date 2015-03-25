export latex

@api latex => LaTeX <: Tile begin
    arg(source::String)
    kwarg(block::Bool=false)
end

render(l::LaTeX) =
    Elem("ka-tex", source=l.source, block=l.block)
