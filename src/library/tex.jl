using LaTeXStrings

export tex

@api tex => (TeX <: Tile) begin
    doc("Create TeX/LaTeX tiles from `LaTeXString` object.")
    arg(source::AbstractString, doc="The source TeX object.")
    kwarg(
        block::Bool=false,
        doc="""If set to true, the resulting tile will be a block. It is inline
             by default"""
    )
end

render(l::TeX, state) = Elem("ka-tex", attributes=@d(:source=>replace(l.source, r"(^\$)|(\$$)", ""), :block=>boolattr(l.block)))

