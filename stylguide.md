# Coding style

- do not break 80 column max-width unless for the occasional long string literals (e.g. Documentation).
- multi-line and wrapping string literals should go on a line below and above code e.g.

    ~~~julia
    foo(
        """one morning gregor samsa
woke up from troubled dreams
"""
    )
    ~~~
    
- use the `@api` macro wherever possible.
- shorthand function expressions can be either:
   - one line (if the line does not exceed 80 characters)
   - or multiple lines but the first line must end with the `=`
- multiline functions must start with a `begin`.
- anonymous functoins should be one line if they do not overflow the line beyond 80 chars
    - otherwise the arguments should come in the line as the assignment. e.g.
 
        ~~~julia
        comm.on_msg = (msg) ->
            push!(sig, decodeJSON(sig, msg.content["data"]["value"]))
        ~~~

- split long function calls like this:

    ~~~julia
    backend = Compose.Patchable(
        Compose.default_graphic_width,
        Compose.default_graphic_height,
    )
    ~~~

  Notice the extra comma at the end. This is to keep diffs clean.
- long ternary expressions should be of the form:
 
    ~~~julia
    foo(x) ?
        case1 :
        case2
    ~~~

- in infix expressions longer than 80 characters, the rhs should be indented
  e.g.

    ~~~julia
    render(t.tile) <<
        Elem(
            "watch-state",
             name=t.name,
             attr=t.attr,
             trigger=t.trigger,
             elem=t.elem,
             source=t.source
        )
    ~~~
    This applies to |>, & and << as well.
