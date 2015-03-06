
export codemirror

immutable CodeMirror <: Widget
    value::String
    mode::String
    theme::String
    linenumbers::Bool
    tabsize::Int
end

codemirror(;
            name=:_code,
            value="",
            mode="julia",
            theme="monokai",
            linenumbers=false,
            tabsize=4) =
    CodeMirror(value, mode, theme, linenumbers, tabsize) |>
        c -> hasstate(c, name=name, attr="value", trigger="keyup")

# Render to virtual DOM
render(c::CodeMirror) =
    Elem("code-mirror",
        value=c.value,
        mode=c.mode,
        theme=c.theme,
        lineNumbers=c.linenumbers)
