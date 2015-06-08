export tex

@api tex => TeX <: Tile begin
    arg(source::String)
    kwarg(block::Bool=false)
end

render(l::TeX) =
    Elem("ka-tex", source=l.source, block=l.block)
