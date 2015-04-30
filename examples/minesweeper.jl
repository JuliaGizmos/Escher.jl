using Compat # for Nullable
using Color

#### Model ####

@defonce immutable Board{lost}
    uncovered::AbstractMatrix
    mines::AbstractMatrix
end

newboard(m, n, minefraction=0.2) =
    Board{false}(fill(-1, (m, n)), rand(m, n) .< minefraction)

function mines_around(board, i, j)
    m, n = size(board.mines)

    a = max(1, i-1)
    b = min(i+1, m)
    c = max(1, j-1)
    d = min(j+1, n)

    sum(board.mines[a:b, c:d])
end

### Update ###

next(board::Board{true}, move) = board
function next(board, move)
    i, j = move
    if board.mines[i, j]
        return Board{true}(board.uncovered, board.mines) # Game over
    else
        uncovered = copy(board.uncovered)
        if uncovered[i, j] == -1
            uncovered[i, j] = mines_around(board, i, j)
        end
        return Board{false}(uncovered, board.mines)
    end
end

movesᵗ = Input((0, 0))
initial_boardᵗ = Input{Any}(newboard(10, 10))
lift(println, initial_boardᵗ)
boardᵗ = flatten(
    lift(Signal, initial_boardᵗ) do b
        foldl(next, b, movesᵗ; output_type=Board)
    end, typ=Any
)

### View ###


colors = ["#fff", colormap("reds", 7)]

box(content, color) =
    inset(Escher.middle,
        fillcolor(color, size(4em, 4em, empty)),
        fontsize(2em, content)) |> paper(1) |> pad(0.2em)

number(x) = box(x == -1 ? "" : string(x) |> fontweight(800), colors[x+2])
mine = box(icon("report"), "#e58")
tile(board::Board{true}, i, j) =
    board.mines[i, j] ? mine :
        number(board.uncovered[i, j])

tile(board, i, j) =
     constant((i, j), clickable(number(board.uncovered[i, j]))) >>> movesᵗ

gameover = vbox(
        title(2, "Game Over!") |> pad(1em),
        Escher.decoder(_ -> newboard(10, 10), watch(button("Start again"))) >>> initial_boardᵗ
    ) |> pad(1em) |> fillcolor("white")

function showboard{lost}(board::Board{lost})
    m, n = size(board.mines)
    b = hbox([vbox([tile(board, i, j) for j in 1:m]) for i in 1:n])
    lost ? inset(Escher.middle, b, gameover) : b
end

function main(window)
    push!(window.assets, "widgets")
    push!(window.assets, "icons")

    lift(Tile, boardᵗ) do board
        vbox(
           vskip(2em),
           title(3, "minesweeper"),
           vskip(2em),
           showboard(board),
        ) |> packacross(center)
    end
end
