export naked

@api naked => (Naked <: Tile) begin
    doc("Send naked html to client")
    arg(value::AbstractString="", doc="The html to send.")
end

# Render to virtual DOM
render(c::Naked, state) =
    Elem("raw-html",
        attributes = @d(
            :value=>c.value
        )
    )


