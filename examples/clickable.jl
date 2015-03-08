using Reactive

clicks = Input(0)

count_left = foldl((x, y) -> x + 1, 0, filter(b->b==1, 0, clicks))
count_right = foldl((x, y) -> x + 1, 0, filter(b->b==2, 0, clicks))
count_scroll = foldl((x, y) -> x + 1, 0, filter(b->b==3, 0, clicks))

main = lift(count_left, count_right, count_scroll) do l, r, s
    vbox(
        clickable([leftbutton, rightbutton, scrollbutton], h1("Click me!")) |> clicks,
        div("Left click count: $l"),
        div("Right click count: $r"),
        div("Scroll button count: $s")) |>
     x -> inset(middle, size(100vw, 100vh, empty), x)
end
