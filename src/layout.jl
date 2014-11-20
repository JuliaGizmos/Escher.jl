import Patchwork.div

export flow, pad, container, position, width, height

function load_layout_css()
    layoutcss = joinpath(Pkg.dir("Canvas"), "assets", "layout.css")
    display(MIME("text/html"), "<style>$(
        readall(open(layoutcss))
    )</style>")
end

try
    load_layout_css()
catch
end

immutable Direction{dir} end
immutable Position{dir} end

typealias Elems AbstractVector

const plaintext = div

flow(dir::Symbol, elems::Elems) = flow(Direction{dir}(), elems)

flow{dir}(::Direction{dir}, elems::Elems) =
    div(className=string("flow direction-", dir), elems)

flow{dir}(::Direction{:left}, elems::Elems) =
    div(className="flow direction-right", reverse(elems))

flow{dir}(::Direction{:up}, elems::Elems) =
    div(className="flow direction-down", reverse(elems))

width(elem::Elem, w::Length) =
    style(elem, :width, string(w))

height(elem::Elem, h::Length) =
    style(elem, :height, string(h))

pad(elem::Elem, pos::Symbol, h::Length) =
    style(elem, string("padding-", pos), string(h))

pad(elem::Elem, h::Length) =
    style(elem, :padding, string(h))

