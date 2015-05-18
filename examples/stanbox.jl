using Markdown
using Color

codewindow(s, name, code; w=40em, h=20em, language="julia") =
    watch!(s, codemirror(code, language=language, name=name)) |> size(w, h)

section(title, content) = vbox(vskip(1em), title, vskip(1em), content)

function inputsui(inputsignal; code="", data="", config="")
    s = sampler()
    form = vbox(
        vskip(2em),
        hbox(h1("Input"), flex(" ")),
        section(h2("Stan Code"), codewindow(s, :code, code)),
        section(h2("Data"), codewindow(s, :data, data)),
        section(h2("Config Input"), codewindow(s, :config, data)),
        section(empty, hbox(trigger!(s, button("Check inputs", name=:check_input)),
                                   watch!(s, button("Run model", name=:run_model)))),
    )

    sample(s, form) >>> inputsignal
end

function process(input)
    # Here input is a dict..
    # You do something to it to make the output
    input
end

function outputsui(output)
    form = vbox(
        vskip(2em),
        h1("Output"),
        string(output)
    ) |> packacross(center)
end

inputsignal = Input(Dict())
inputs = inputsui(inputsignal)

fullui(inputs, output) =
    vbox(hbox(title(3, "Stan playground"), hskip(1em), caption(md" beta")),
        vskip(2em),
        md"""Hello from **Markdown**. This is an interface to the `Stan` package.""",

        hbox(flex(inputs), hskip(1em), flex(output))) |> pad(2em) |> width(96em)


function main(window)
    push!(window.assets, "widgets")
    push!(window.assets, "icons")
    push!(window.assets, "codemirror")

    lift(input -> hbox(flex(), fullui(inputs, outputsui(process(input))), flex()), inputsignal)
end

