# HTML tables

export table

using DataFrames

# Model

immutable Table <: Tile
    head::AbstractVector
    body::AbstractDataFrame
end

table(body; head=Array(Tile, 0)) =
    Table(head, body)

# Behaviors

immutable SelectRows
    multi::Bool
    table::Table
end

immutable SelectCols
    multi::Bool
    table::Table
end

# Render logic

render_cell(x) =
    Elem(:td, render(x))

render(t::Table) = begin
    if length(t.head) > 0
        @assert length(t.head) == ncol(t.body)
        head = t.head
    else
        head = names(t.body)
    end

    Elem(:table,
        [Elem(:thead, Elem(:tr, map(x -> Elem(:th, render(x)), head))),
         Elem(:tbody,
            [Elem(:tr, [render_cell(v) for (k,v) in row])
                for row in eachrow(t.body)]
         )]
    )
end
