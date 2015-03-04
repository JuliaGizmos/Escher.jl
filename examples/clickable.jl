using Reactive

clicks = Input(0)

count_left = foldl((x, y) -> x + 1, 0, filter(b->b==1, 0, clicks))
count_right = foldl((x, y) -> x + 1, 0, filter(b->b==2, 0, clicks))
count_scroll = foldl((x, y) -> x + 1, 0, filter(b->b==3, 0, clicks))

main = lift(count_left, count_right, count_scroll) do l, r, s
    flow(down, [
        clickable([leftbutton, rightbutton, scrollbutton], h2("Click me!")) |> clicks,
        div(string("Left click count: $l")),
        div(string("Right click count: $r")),
        div(string("Scroll button count: $s"))]) |>
     x -> inset(middle, snugfit(), x)
end
