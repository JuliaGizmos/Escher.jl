using Compat # for Nullable

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

tile(x) =
    inset(Escher.middle,
        fillcolor("#999", size(4em, 4em, empty)),
        fontsize(2em, x)) |> paper(2) |> pad(0.5em)

content(x) = x == -1 ? "" : string(x)

function tile(board::Board{true}, i, j)
    board.mines[i, j] ? tile("*") :
        tile(content(board.uncovered[i, j]))
 end

tile(board, i, j) =
     constant((i, j), clickable(tile(content(board.uncovered[i, j])))) >>> movesᵗ

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
           title(3, "Minesweeper"),
           showboard(board),
        ) |> packacross(center)
    end
end
