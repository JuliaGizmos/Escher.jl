
export codemirror

@api codemirror => (CodeMirror <: Widget) begin
    doc("Create a code viewer/editor")
    arg(code::AbstractString="", doc="The code to display.")
    kwarg(name::Symbol=:_code, doc="The name for the widget")
    kwarg(readonly::Bool=false, doc="If set to true, editing will be disabled.")
    kwarg(language::AbstractString="julia", doc="The language used for syntax highlighting.")
    kwarg(
        theme::AbstractString="elegant",
        doc=md"""The theme. Valid values are `"ambiance"`,`"ambiance-mobile"`,
                 `"elegant"`, `"monokai"`, `"solarized"` and `"twilight"`."""
    )
    kwarg(linenumbers::Bool=true, doc="If set to true, line numbers will be shown.")
    kwarg(tabsize::Int=4, doc="The tab size.")
end

wrapbehavior(c::CodeMirror) =
    hasstate(c, name=c.name, attr="immediateValue", trigger="change")

# Render to virtual DOM
render(c::CodeMirror, state) =
    Elem("code-mirror",
        attributes = @d(
            :value=>c.code,
            :mode=>c.language,
            "read-only"=>boolattr(c.readonly),
            :theme=>c.theme,
            "line-numbers"=>boolattr(c.linenumbers),
        )
    )
