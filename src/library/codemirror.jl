
export codemirror

@api codemirror => (CodeMirror <: Widget) begin
    doc("Create a code viewer/editor")
    arg(code::String="", doc="The code to display.")
    kwarg(name::Symbol=:_code, doc="The name for the widget")
    kwarg(readonly::Bool=false, doc="If set to true, editing will be disabled.")
    kwarg(language::String="julia", doc="The language used for syntax highlighting.")
    kwarg(
        theme::String="elegant",
        doc=md"""The theme. Valid values are `"ambiance"`,`"ambiance-mobile"`,
                 `"elegant"`, `"monokai"`, `"solarized"` and `"twilight"`."""
    )
    kwarg(linenumbers::Bool=true, doc="If set to true, line numbers will be shown.")
    kwarg(tabsize::Int=4, doc="The tab size.")
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
