using Canvas
using DataFrames

import Canvas.render


main = inset(Canvas.middle,
    snugfit(),
    table(DataFrame(x=rand(10), y=rand(10))))
