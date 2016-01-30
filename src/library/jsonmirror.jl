export jsonmirror
@api jsonmirror => (JsonMirror <: Widget) begin
    doc("Sync Json Data between server and client")
    arg(json::AbstractString="{}", doc="The json to sync.")
    kwarg(name::Symbol=:_json, doc="The name for the widget")
    kwarg(oneway::Bool=true, doc="Two way binding or one way(true).")
    kwarg(id::AbstractString=replace(string("$(rand(1)[1])"),r"[0-9]\.","idx-"), doc="The unique id of the object.")
end

wrapbehavior(c::JsonMirror) =
    hasstate(c, name=c.name, attr="immediateValue", trigger="change")

# Render to virtual DOM
render(c::JsonMirror, state) =
    Elem("json-mirror",
        attributes = @d(
            :json=>c.json,
	    :name=>c.name,
	    :id=>c.id,
            "oneway"=>boolattr(c.oneway)
        )
    )
