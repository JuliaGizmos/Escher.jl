
# An infinite number of mathematicians walk into a bar...

using Canvas
using Color

colors = distinguishable_colors(9)

box(w, h, n) =
    (div(" ") & [:style =>
        ["backgroundColor" => "#" * hex(colors[n % 9 + 1])]]) |> size(w, h)

cut(w, h, dir::Canvas.Up) =
    (w, h/2)
cut(w, h, dir::Canvas.Down) =
    (w, h/2)
cut(w, h, dir) =
    (w/2, h)

stack(w, h, d, n) =
    n == 0 ?
        empty :
        flow(d[1], [ box(cut(w, h, d[1])..., n),
            stack(cut(w, h, d[1])..., vcat(d[2:end], d[1]), n-1)])

main = place(middle,
             stack(80vmin, 80vmin, [down, left, up, right], 11),
             snugfit())
