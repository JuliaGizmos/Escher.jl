
export codemirror

immutable CodeMirror <: Widget
    code::String
    language::String
    theme::String
    linenumbers::Bool
    tabsize::Int
end

codemirror(;
            name=:_code,
            code="",
            language="julia",
            theme="elegant",
            linenumbers=true,
            tabsize=4) =
    CodeMirror(code, language, theme, linenumbers, tabsize) |>
        c -> hasstate(c, name=name, attr="currentValue", trigger="change")

# Render to virtual DOM
render(c::CodeMirror) =
    Elem("code-mirror",
        value=c.code,
        mode=c.language,
        theme=c.theme,
        lineNumbers=c.linenumbers)
