
export codemirror

immutable CodeMirror <: Widget
    value::String
    mode::String
    theme::String
    linenumbers::Bool
    tabsize::Int
end

codemirror(;
            value="",
            mode="julia",
            theme="monokai",
            linenumbers=false,
            tabsize=4) =
    CodeMirror(value, mode, theme, linenumbers, tabsize)

# Render to virtual DOM
render(c::CodeMirror) =
    custom("code-mirror") & [
        "value" => c.value,
        "mode" => c.mode,
        "theme" => c.theme,
        "lineNumbers" => c.linenumbers]
