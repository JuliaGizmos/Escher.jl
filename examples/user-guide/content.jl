include("helpers/listing.jl")

hello_str = "\"Hello, World\""

isinstalled(pkg) = try Pkg.installed(pkg) != nothing catch e false end

md_str = """
md\"\"\"
## This is a heading

*italic*, **bold** and `monospace`.

- one
- two
- three

Code:

```julia
function foo()
    42
end
foo()
```
\"\"\" """

function main(window)
    push!(window.assets, "widgets")
    push!(window.assets, "codemirror")
    push!(window.assets, "tex")

    vbox(
        title(3, "Content"),

        vskip(1em),
        h2("String"),
        "A string is rendered as-is to plain text",
        vskip(1em),
        listing(hello_str),

        vskip(1em),
        h2("Markdown"),
        "Markdown strings get rendered appropriately.",
        vskip(1em),
        listing(md_str),

        vskip(1em),
        h2("Code"),
        md"""To show code with syntax highlighting, you can use the `codemirror` function. Codemirror requires the `"codemirror"` asset. 
        
        Use `push!(window.assets, "codemirror")` to do this.""",
        vskip(1em),
        listing("""
            push!(window.assets, "codemirror")
            
            codemirror(\"\"\"
                function foo()
                42
                end
                \"\"\"
            )
            """,
            codemirror("""
                function foo()
                    42
                end
                """
            )
        ),
        md"""Note that you also need the `"codemirror"` asset to be loaded even if you are writing code inside `md`.""",

        vskip(1em),
        h2("LaTeX"),
        md"LaTeX strings can be rendered with the `tex` function.",
        vskip(1em),
        listing("""
        tex("(a+b)^2=a^2+b^2+2ab")"""),
        
        md"[SymPy.jl](https://github.com/jverzani/SymPy.jl) can be used to generate mathematical expressions. Escher automatically typesets them to LaTeX.",
        vskip(1em),
        listing("""
        using SymPy
        Escher.external_setup() # sets up rendering of SymPy symbols

        x = Sym("x")
        SymPy.diff(sin(x^2), x, 5)""",
        isinstalled("SymPy") ? nothing : "SymPy.jl is not installed."),

        h2("Images"),
        md"External images can be included using the `image` function.",
        vskip(1em),
        listing("""
        image(
            "https://upload.wikimedia.org/wikipedia/en/thumb/2/24/Lenna.png/220px-Lenna.png",
            alt="Lenna",
        )
        """),
        
        md"Images can also be read in from the [`Images.jl`](https://github.com/timholy/Images.jl/) package.",
        vskip(1em),
        listing("""
        using Images
        Escher.external_setup() # sets up rendering of Image objects
        grayim(rand(100,100))
        """,
        isinstalled("Images") ? nothing : "Images.jl is not installed."),

    ) |> pad(2em)
end
