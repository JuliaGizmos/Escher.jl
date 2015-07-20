
export codemirror

@api codemirror => CodeMirror <: Widget begin
    arg(code::String="")
    kwarg(name::Symbol=:_code)
    kwarg(readonly::Bool=false)
    kwarg(language::String="julia")
    kwarg(theme::String="elegant")
    kwarg(linenumbers::Bool=true)
    kwarg(tabsize::Int=4)
end

broadcast(c::CodeMirror) =
    hasstate(c, name=c.name, attr="currentValue", trigger="change")

# Render to virtual DOM
render(c::CodeMirror, state) =
    Elem("code-mirror",
        value=c.code,
        mode=c.language,
        readOnly=c.readonly,
        theme=c.theme,
        lineNumbers=c.linenumbers)
