
# Function that executes code and
# returns the result
execute_code(code) = begin
    try
        parse("begin\n" * code * "\nend") |> eval
    catch ex
        sprint() do io
            showerror(io, ex)
            println(io)
            Base.show_backtrace(io, catch_backtrace())
        end
    end
end

## View

# Code mirror to input some code
showinput(code;kwargs...) = begin
    s = sampler()

    intent(s,
        codemirror(code; kwargs...) |>
        watch!(s, :code) |>
        keypress("ctrl+enter") |>
        trigger!(s, :submit))
end

getcode(x) = x[:code]
code_io(code, code_input; kwargs...) = begin
    intent(getcode, showinput(code; kwargs...)) >>> code_input
end

# Output area
showoutput(code) = begin
    obj = try
        execute_code(code)
    catch ex
        sprint() do io
            bt = catch_backtrace()
            showerror(io, ex)
            println(io)
            Base.show_backtrace(io, bt)
        end
    end
    try
        convert(Tile, obj)
    catch codemirror(string(obj), readonly=true, linenumbers=false)
    end
end

# REPL
newrepl() = vbox(empty)
function append_execution(repl, code)
    cell_sig = Signal(code)
    println(cell_sig)
    vbox(
        vcat(
            repl.tiles.tiles,
            vbox(
                code_io(code, cell_sig, linenumbers=false),
                map(showoutput, cell_sig)
            )
        )
    )
end

