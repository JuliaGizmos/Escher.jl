# HTML tables

using Patchwork.HTML5

export table

using DataFrames

# Model

immutable Table <: Tile
    head::AbstractVector
    body::AbstractDataFrame
end

table(body; head=Array(Tile, 0)) =
    Table(head, body)

# Behaviours

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
    td(render(x))

function render(t::Table)
    if length(t.head) > 0
        @assert length(t.head) == ncol(t.body)
        head = t.head
    else
        head = names(t.body)
    end

    Elem(:table,
        [thead(tr(map(x -> th(render(x)), head))),
         tbody(
            [tr([render_cell(v) for (k,v) in row])
                for row in eachrow(t.body)]
         )]
    )
end
