export tex

@api tex => (TeX <: Tile) begin
    doc("Show TeX/LaTeX.")
    arg(source::AbstractString, doc="The source TeX code.")
    kwarg(
        block::Bool=false,
        doc="""If set to true, the resulting tile will be a block. It is inline
             by default"""
    )
end

render(l::TeX, state) =
    Elem("ka-tex", attributes=@d(:source=>l.source, :block=>boolattr(l.block)))
