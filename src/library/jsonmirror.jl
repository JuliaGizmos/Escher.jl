export jsonmirror

@api jsonmirror => (JsonMirror <: Widget) begin
    doc("Sync Json Data between server and client")
    arg(json::AbstractString="", doc="The json to sync.")
    kwarg(readonly::Bool=true, doc="Two way binding or one way(true).")
    kwarg(autoNotify::Bool=false, doc="Tell the server on every change automatically? WARNING: This can cause endless recursion.")
    kwarg(uid::AbstractString=replace(string("$(rand(1)[1])"),r"[0-9]\.","idx-"), doc="The unique id of the object.")
    kwarg(category::AbstractString="jsonmirror", doc="Object class.")
end

wrapbehavior(c::JsonMirror) =
	hasstate(c, attr="immediateValue", trigger="change")

# Render to virtual DOM
render(c::JsonMirror, state) =
    Elem("json-mirror",
        attributes = @d(
            :value=>c.json,
	    "read-only"=>boolattr(c.readonly),
	    :uid=>c.uid,
	    :category=>c.category,
	    :autoNotify=>c.autoNotify
        )
    )

