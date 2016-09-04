include("helpers/listing.jl")
using Colors

function main(window)
    push!(window.assets, "widgets")
    push!(window.assets, "date")
    push!(window.assets, "codemirror")
    push!(window.assets, "tex")
    colors = ["violet", "blue", "green", "yellow", "orange", "red"]
    colortile(c, w, h) = fillcolor(c, size(w, h, empty))

    vbox(
        title(3, "Widgets"),
        md"""Escher provides a set of input widgets that can be used to create
        dynamic UIs that take inputs from users and are interactive. Widgets
        require the `widgets` asset to be pushed to the window to render and
        behave correctly. This is done with `push!(window.assets, "widgets")`.

        Escher follows the concept of reactive programming and uses Reactive.jl
        to implement this. The Escher workflow for creating dynamic UIs can be
        broken down into the following workflow.

        - Create a `Signal`
        - Create a `Widget` and subscribe the `Signal` to the `Widget`. Updates on the widgets will now reflect
        to the `Signal`.
        - Use `map` to update a UI based on the value of the `Signal`

        """,
        h3(md"Sliders"),
        md"""
        Sliders are very useful input widgets for taking inputs in a certain range.
        They are well suited to be used for users to input numerical inputs, such
        as the number of iterations for a simulation to run. Sliders can be created
        using the `slider` function and providing a range as the input. The starting
        value can also be provided using the `value` keyword argument.
        """,
        listing(
            """
            # Create a Signal
            inp = Signal(5.0)
            # Create a slider and subscribe it to the signal
            s = subscribe(
                    inp,
                    slider(1.0:9.0, value=5.0)
                )
            # Map the signal and create a dynamic UI
            map(inp) do val
                vbox(
                    "Adjust the slider to see the value update",
                    s, #the slider!
                    string(val) #the value
                )
            end
            """
        ),
        md"""The above pattern is followed for the rest of the input widgets in
        Escher too. We use the slider to present a more involved example below.
        """,
        listing(
            """
            # Colortile set up
            colors = ["violet", "blue", "green", "yellow", "orange", "red"]
            colortile(c, w, h) = fillcolor(c, size(w, h, empty))
            colortiles = [colortile(c, 4em, 4em) for c in colors]
            # Create a Signal
            n = Signal(1)
            # Shortcut to subscribe
            nslider = slider(1:length(colors)) >>> n
            # Mapping the signal and creating a dynamic UI
            map(n) do val
                vbox(
                    "Adjust the slider to display that many colortiles",
                    nslider,
                    vskip(1em),
                    hbox(
                    colortiles[1:val]...
                    )
                )
            end
            """
        ),
        md"""Notice how we use `>>>` as syntactic sugar instead of `subscribe`.""",
        h3("Buttons"),
        md"""Buttons can be created using `button` and providing a label. We can
        also set the button to be disabled, or raised using keywords. Buttons can
        be used in UI's to allow users to update the UI by clicking it, like run
        a simulation again.
        """,
        listing(
        """
            colors = ["violet", "blue", "green", "yellow", "orange", "red"]
            colortile(c, w, h) = fillcolor(c, size(w, h, empty))
            inp = Signal{Any}(nothing)
            b = button("Shuffle tiles") >>> inp
            map(inp) do _
                vbox(
                    b,
                    vskip(1em),
                    hbox(
                    [
                    colortile(color, 4em, 4em)
                    for color in shuffle(colors)
                    ]
                    )
                )
            end
        """
        ),
        h3(md"Checkbox"),
        md"""
        Checkboxes are a great way to take boolean inputs like allowing users to specify what content to display.
        They act like `Bool`s and can have values of either `true` and `false`.
        """,
        listing(
        """
            colors = ["violet", "blue", "green", "yellow", "orange", "red"]
            colortile(c, w, h) = fillcolor(c, size(w, h, empty))
            signals = [Signal(true) for i=1:length(colors)]
            checkboxes = [checkbox(true, colors[i]) >>> signals[i] for i=1:length(colors)]
            function checkboxtile(signal, checkbox, color)
                map(signal) do val
                    vbox(
                    checkbox,
                    if val
                        colortile(color, 4em, 4em)
                    else
                        colortile("white", 4em, 4em)
                    end
                    ) |> width(5em)
                end
            end

            hbox(
                [checkboxtile(signals[i], checkboxes[i], colors[i]) for i in 1:length(colors)]
            )
        """
        ),
        h3(md"Togglebuttons"),
        md"""
        Togglebuttons can be created using `togglebutton`. They are also like checkboxes,
        but do not have labels. They also act like `Bool`s and can have values of either `true` and `false`.
        """,
        listing(
        """
            colors = ["violet", "blue", "green", "yellow", "orange", "red"]
            colortile(c, w, h) = fillcolor(c, size(w, h, empty))
            colortiles = [colortile(c, 4em, 4em) for c in colors]
            disp = Signal(false)
            t = togglebutton(false) >>> disp
            map(disp) do disp
                vbox(
                    hbox("Hide",t),
                    vskip(1em),
                    if disp
                        "Tiles Hidden!"
                    else
                        hbox(colortiles)
                    end
                )
            end
        """),
        h3(md"Radio Groups"),
        md"""
        Radio buttons can be created using `radio`. We combine several of these
        `radio` buttons in a `radiogroup`. In one group, only one button can
        be selected at any one time. This can be used to provide a list of choices
        to users from which only one can be selected.
        """,
        listing(
        """
            colors = ["violet", "blue", "green", "yellow", "orange", "red"]
            colortile(c, w, h) = fillcolor(c, size(w, h, empty))

            selected = Signal("violet")
            r = radiogroup([radio(c, c) for c in colors], selected="violet") >>> selected
            map(selected) do c
                vbox(
                    r,
                    colortile(c, 4em, 4em)
                )
            end
        """
        ),
        h3(md"Text input"),
        md"""
        The text input widget can be used to take text input from users. It can
        be created using `textinput`. We can
        set pattern validation and display error messages in the case of invalid
        input. Character counters and multiline inputs can also set!
        """,
        listing(
            """
            text = Signal("")
            textwidget = textinput(
                label="Type here", multiline=true, charcounter=true
                ) >>> text
            map(text) do val
                vbox(
                    textwidget,
                    val
                )
            end
            """
        ),
        #=
        h3("Date Picker"),
        md"""
        Date pickers are a great way of allowing users to choose dates. `datepicker`
        can be used to create such a date picker in Escher.
        """,
        listing(
            """
            datechosen = Signal(Dates.today())
            datewidget = datepicker(Dates.today())
            map(datechosen) do d
                vbox(
                    datewidget,
                    d
                )
            end
            """
        ),=#
        h3(md"Codemirror"),
        md"""
        We can set up a codemirror input widget using `codemirror`. Syntax highlighting,
        tab indents, themes, line indents etc can be set using the keywork arguments. This requires
        us to push the `codemirror` asset first by doing `push!(window.assets, "codemirror")`.
        """,
        listing(
            """
            code = Signal("1+1")
            codewidget = codemirror("1+1") >>> code
            map(code) do code
                vbox(
                    codewidget,
                    eval(parse(code))
                )
            end
            """
        )
    ) |> pad(2em)
end
