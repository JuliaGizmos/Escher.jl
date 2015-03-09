
export codemirror

immutable Code <: Tile
    language::String
    code::Tile
end

code(language, c) = Code(language, c)
code(c) = code("julia", c)

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
            theme="monokai",
            linenumbers=true,
            tabsize=4) =
    CodeMirror(code, language, theme, linenumbers, tabsize) |>
        c -> hasstate(c, name=name, attr="value", trigger="keyup")

# Render to virtual DOM
render(c::CodeMirror) =
    Elem("code-mirror",
        value=c.code,
        mode=c.language,
        theme=c.theme,
        lineNumbers=c.linenumbers)
