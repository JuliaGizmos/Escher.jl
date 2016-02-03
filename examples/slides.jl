using Markdown
using Color
using SymPy
using Compose
using Gadfly
using Images

include("repl.jl")

presentable(x) = Escher.fontsize(1.5em, lineheight(2em, x))

Compose.set_default_graphic_size(4Compose.inch, (2*√3)*Compose.inch)

codeslide(code) = begin
    input = Input(code)
    hbox(
        code_io(code, input) |> size(27em, 37em),
        hskip(1em),
        vbox(
            lift(showoutput, input, typ=Any)
        ) |> size(25em, 35em) |> Escher.pad(1em) |> fillcolor("white") |> roundcorner(0.5em)
    ) |> Escher.pad(1em) |> fillcolor("#e1e4e8") |> paper(2)
end

indent(x) = Escher.pad([left], 3em, x) |> Escher.fontsize(0.8em) |> lineheight(1.5em)

function main(window)
    push!(window.assets, "animation")
    push!(window.assets, "widgets")
    push!(window.assets, "tex")
    push!(window.assets, "layout2")
    push!(window.assets, "codemirror")

    slideshow([
        vbox(
            title(2, "What?"),
            title(3, "A Virtual DOM on the Server?"),
            vskip(4em),
            title(1, "Shashi Gowda"),
            title(1, "@g0wda"),
            title(1, "shashi.github.io/Escher.jl")
        ),
        title(2, md"Yes. Settle for nothing less!"),
        title(2, md"\"Recommendation system\": 33 SLOC"),
        title(2, md"Trade data viewer: 194 SLOC"),
        title(2, md"2D FFT of video stream: 13 SLOC"),
        title(2, md"A sierpinski's triangle: 24 SLOC"),
        title(2, md"Minesweeper: 70 SLOC"),
        #include(joinpath(pwd(), "minesweeper.jl"))(window),
        title(2, md"Boids: 84 SLOC (credits: Iain Dunning github.com/IainNZ)"),
        title(3, "But how?"),
        vbox(
            title(3, "The DOM"),
            vskip(2em),
            title(4, "¯\\_(ツ)_/¯"),
        ) |> packacross(center),
        vbox(
            title(3, "DOM is state."),
            vskip(2em),
            title(1, "Bad DOM!"),
            vskip(2em),
            vbox(
                md"- State leads to combinatorial explosion.",
                  md"- Average person can hold < 10 things in his brain at a time" |> indent,
                  md"- But 2^50 = 10^15, there are 10^11 stars in the Milky Way" |> indent,
                md"- State and Callback are the evil king and queen",
                  md"""
                  - They necessitate each other
                  - We increasingly understand that callbacks are not ideal""" |> indent,
              ) |> presentable
        ),
        vbox(
            title(3, "Virtual DOM"),
            vskip(1em),
            "The Insurgency" |> Escher.fontsize(1.5em),
            vskip(1em),
            vbox(
                md"- Enables stateless functions",
                md"""
                  - A very simple model
                  - `f : Data -> UI`
                  - What you are doing actually fits in your head
                """ |> indent,
                md"- One clever trick: DOM reconciliation",
                md"- managed efficiency" |> indent,
                md"- Gets along oh so well with FRP",
                md"- An escape hatch from Callback Hell" |> indent
            ) |> presentable
        ),
        vbox(
            title(3, "Over to the dark side!"),
            vskip(1em),
            title(2, "Virtual DOM on the server"),
            vskip(3em),
            image("http://i.giphy.com/UY6K0O5xNeG2s.gif", alt="The Eye of Sauron"),
        ),
        vbox(
            title(3, "Virtual DOM is the substrate"),
            vskip(2em),
            title(2, "Patchwork.jl"),
            title(1, "github.com/shashi/Patchwork.jl"),
            vskip(1em),
            title(2, "virtual-dom"),
            title(1, "github.com/Matt-Esch/virtual-dom"),
        ),
        vbox(
            title(3, md"Patchwork.jl provides the `Elem` type"),
            vskip(2em),
            codeslide("""
            Elem(:div, "Hello, World",
                style=[
                  :padding => 1em,
                  :backgroundColor => "steelblue",
                  :color => "white"
                ]
            )""")
        ),
        slide(vbox(
            title(3, md"Patchwork.jl provides the `Elem` type"),
            vskip(2em),
            codeslide("""
                mkcircle(x, y, r, color="lightgrey") =
                    Elem(:svg, :circle,
                        cx=x, cy=y, r=r,
                        style=[:fill => color],
                    )

                Elem(:svg, :svg, [
                    mkcircle(100, 100, 50),
                    mkcircle(100, 200, 70),
                    mkcircle(100, 100, 10, "orange"),
                    mkcircle(80, 80, 10, "white"),
                    mkcircle(120, 80, 10, "white"),
                 ], width=500px, height=500px)
                """)
        ), transitions="cross-fade-all"),
        slide(vbox(
            title(3, md"HTML5 Custom Elements work with Virtual DOM!"),
            vskip(2em),
            codeslide("""
            Elem("ka-tex",
                source=\"\"\"
                    cos(2\\\\theta) =
                    cos^2 \\\\theta - sin^2 \\\\theta\"\"\",
                block=true
            )

            # code-mirror
            """)
        ) |> packacross(center), transitions="cross-fade-all"),
        vbox(
            title(4, "Escher.jl"),
            vskip(1em),
            title(1, "shashi.github.io/Escher.jl"),
            vskip(1em),
            "Delicious layers of pixie dust on top of Virtual DOM" |> Escher.fontsize(1.5em)
        ),
        vbox(
            title(1, md"Abstraction 1"),
            title(2, md"Content: Julia Values to Virtual DOM"),
        ),
        vbox(
            title(2, md"Content: Textual"),
            codeslide("""
            "Hello, World"


            # Markdown
            # CodeMirror
            #
            # using SymPy
            # x = Sym("x")
            # SymPy.diff(sin(x^2), x, 5)
            """)
        ),
        vbox(
            title(2, md"Content: Vector graphics"),
            codeslide("""
            using Compose

            function sierpinski(n::Int)
                if n == 0
                    compose(context(), polygon([(1,1), (0,1), (1/2, 0)]))
                else
                    t = sierpinski(n - 1)
                    compose(context(),
                            (context(1/4,   0, 1/2, 1/2), t),
                            (context(  0, 1/2, 1/2, 1/2), t),
                            (context(1/2, 1/2, 1/2, 1/2), t))
                end
            end

            drawing(4inch, (2*√3)*inch,
                sierpinski(2))
            """)
        ),
        vbox(
            title(2, md"Content: Plots"),
            codeslide("""
            using Gadfly

            plot([sin, cos], 0, 25)
            #plot(z=(x,y) -> x*exp(-(x-int(x))^2-y^2),
            #     x=linspace(-8,8,150), y=linspace(-2,2,150), Geom.contour)
            """)
        ),
        vbox(
            title(1, md"Abstraction 2"),
            title(2, md"TeX-style Layouts"),
        ),
        vbox(
            hbox(title(2, md"Layouts"), hskip(1em), "" |>
                Escher.fontsize(1.5em)) |>
                packacross(center),
            codeslide("""
            # using Color
            colors = colormap("reds", 7)

            box1 = container(10em, 10em) |>
                     fillcolor(colors[3])
            box2 = container(5em, 5em) |>
                     fillcolor(colors[5])

            vbox(box1, box2)
            #boxes = [container(i*em, i*em) |>
            #    fillcolor(colors[i])
            #       for i=1:7]

            """)
        ),
        vbox(
            hbox(title(2, md"Layouts: padding and inset"), hskip(1em), "" |>
                Escher.fontsize(1.5em)) |>
                packacross(center),
            codeslide("""
            x = Escher.pad(1em, box1)

            #
            # inset(offset(middle, 5em, 4em), container(10em, 10em) |> fillcolor("tomato"), x)
            #
            """)
        ),
        vbox(
            md"""[CSS] is so complex that it has never been implemented correctly; yet, successive versions specify even more complexity. At the same time, it is so underpowered that many elementary graphic designs are impossible or prohibitively difficult, and context-sensitivity (or anything computational) must be addressed externally. Most CSS lore is dedicated to describing the tangles of brittle hacks needed to circumvent incompatibilities or approximate a desired appearance.""" |> maxwidth(30em),
            md"-- Bret Victor *MagicInk*"
        ) |> presentable,
        vbox(
            md"""One cause of the CSS mess is the eschewing of elegant, flexible abstractions for “1000 special cases,” a detrimental approach which precludes simplicity and generality in any domain. However, the larger and more germane fault is the language’s attempt to serve as both *tool* and *platform*, thereby succeeding as neither.""" |> maxwidth(30em),
            md"-- Bret Victor *MagicInk*"
        ) |> presentable,
        vbox(
            hbox(title(2, md"Layout 2"), hskip(1em), "" |>
                Escher.fontsize(1.5em)) |>
                packacross(center),
            codeslide("""
            t = tabs([
                hbox(icon("star-half"), hskip(1em), "Vector graphics"),
                hbox(icon("trending-up"), hskip(1em), "Plots"),
            ])
            p = pages([
               sierpinski(2),
               plot([sin, cos], 0, 25),
            ])

            t, p = wire(t, p, :tabs, :selected)
            vbox(t, p)
            """)
        ),
        vbox(
            title(1, md"Abstraction 3"),
            title(2, md"Typography"),
        ),
        vbox(
            hbox(title(2, md"Typography"), hskip(1em), "" |>
                Escher.fontsize(1.5em)) |>
                packacross(center),
            codeslide("""

            samples = vcat(
               [Escher.title(i, "Title \$i")
                   for i=1:4],
               [heading(i, "Heading \$i")
                   for i=4:-1:1]
            )

            vbox(
                samples
            )
            """)
        ),
        vbox(
            title(2, md"Interactivity"),
            title(1, md"Introducing the time dimension"),
        ),
        vbox(
            h1("The story so far"), vskip(1em), title(3, tex("UI = f(data)")),
        ),
        vbox(
            title(3, md"We turn to reactive programming"),
            title(2, md"Inspiration: Elm"),
            title(1, md"elm-lang.org"),
            title(2, md"Reactive.jl"),
            title(1, md"github.com/JuliaLang/Reactive.jl"),
        ),
        vbox(
            title(2, md"The Signal primer"),
            title(3, md"Think *circuitry*"),
            title(2, md"`dataₜ ⇝ f ⇝ outputₜ`"),
        ) |> packacross(center),
        vbox(
           title(2, "Signal: first principles"),
           vskip(2em),
           md"""- A signal has a value at any given time
              - The value held by a signal can change as time passes""" |> presentable,
        ),
        vbox(
           title(2, "Input Signal"),
           vskip(1em),
           "An input signal is created as below. It must have a default value." |> presentable,
           vskip(1em),
           codemirror("int_signal = Input(0)"),
           md"The value held by an input signal can be updated with `push!`" |> presentable,
           codemirror("push!(int_signal, 42)"),
        ),
        vbox(
           title(2, "Functions that operate on signals"),
           vskip(2em),
           codemirror("""
           consume     : (Function, Signal) ⟶ Signal
           foldl       : (Function, initial_value, Signal) ⟶ Signal
           filter      : (Function, default_value, Signal) ⟶ Signal
           merge       : (Signal...) ⟶ Signal
           droprepeats : (Signal) ⟶ Signal
           keepwhen    : (Signal{Bool}, Signal) ⟶ Signal
           fps         : (Float64) ⟶ Signal
           fpswhen     : (Signal{Bool}, Float64) ⟶ Signal
           """, linenumbers=false) |> fonttype(monospace) |> presentable
        ),
        vbox(
           title(2, md"consume example: turning `Input` into a signal of UIs"),
           codeslide("""
           steps = Input(0)

           steps_slider =
               subscribe(slider(0:6), steps)

           vbox(
               steps_slider,
               consume(sierpinski, steps),
           )
           """),
        ),
        vbox(
           title(2, "consume example: Animation"),
           vskip(1em),
           codeslide("""
           switch_state = Input(false)
           switch = subscribe(togglebutton(false),
                              switch_state)

           ticks = fpswhen(switch_state, 60)

           showball(x) =
             compose(context(),
               circle(.5,
                 .1 + (1-abs(sin(2*time()))) * 0.8,
                 .1
               ), fill("tomato"))
           vbox(
               switch,
               consume(showball, ticks),
           )
           """),
        ),
        title(3, "What makes a Widget?"),
        vbox(
            title(1, "Abstraction 4"),
            title(3, "Behavior"),
        ),
        vbox(
            title(2, "Behavior"),
            vskip(1em),
            codeslide("""
            clickme = clickable("Click me!" |>
                        Escher.fontsize(2em) |>
                        fontweight(500))

            clicks = Input{Escher.MouseButton}(
                       leftbutton
            )

            vbox(
                subscribe(clickme, clicks),
                foldl((cnt, _) -> cnt + 1, 0, clicks),
            )
            """)
        ),
        vbox(
            title(2, "What's in the DOM?"),
            vskip(1em),
            md"""
            - `clickable-behavior` adds a click event listener to its parent
            - it can be configured to listen for different mouse buttons
            - `signal-transport` updates a signal with a `signalId` on the server
            - `stop-propagation` stops the event from bubbling up to prevent clashes
            """ |> presentable
        ),
        vbox(
            title(2, "Other behaviors include"),
            vskip(1em),
            md"""
            - `hasstate`: watch for attribute X when event Y is fired
            - `keypress`: watch for certain keypresses
            """ |> presentable
        ),
        vbox(
            title(1, "Abstraction (Julia-side) 5"),
            title(3, "Interpreters"),
        ),
        vbox(
            title(2, "Why do we need interpreters?"),
            vskip(1em),
            md"""
            - Each behavior results in a certain kind of values. e.g. Clicks are of the type `MouseButton`
            - Interpreters allow us to decode and augment messages coming from the browser
            """ |> presentable
        ),
        vbox(
            title(2, md"Interpreter example: `constant`"),
            vskip(1em),
            codeslide("""
            delta = Input(0)

            inc = constant(1, button("+")) >>> delta
            dec = constant(-1, button("-")) >>> delta

            count = foldl(+, 0, delta)

            hbox(
                inc,
                hskip(1em),
                title(2, count),
                hskip(1em),
                dec
            )
            """)
        ),
        vbox(
            title(2, "Widget = UI + Behavior + Interpreter"),
            md"""
            For example,,
            
            a slider has a default behaviour of `WatchState` and an interpreter `ToType{Real}`
            """ |> presentable,
        ),
        vbox(
            title(2, "Real world code walk-through"),
        ),
        #image("/assets/img/dynamicui.png"),
        #include(joinpath(pwd(), "latex.jl"))(window),
        vbox(
            title(3, "Thanks for the inspiration, and code!"),
            md"""
            - Elm
            - virtual-dom
            - Polymer
            - $\KaTeX$
            """ |> lineheight(2em) |> Escher.fontsize(2em)
        ),
        vbox(
            title(3, "Thanks for the inspiration, and code!"),
            md"""
            - Compose, Gadfly
            - Images
            - SymPy
            """ |> lineheight(2em) |> Escher.fontsize(2em)
        ),
        vbox(
            title(3, "Thank you for listening!"), vskip(1em),
            title(2, "https://shashi.github.io/Escher.jl"), vskip(1em),
            title(1, "or just google Escher.jl"),
        ),
    ])
end

