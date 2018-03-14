import Escher: slider, listbox, wrapitem, menu

main(window) = begin
    push!(window.assets, "layout2")
    push!(window.assets, "icons")
    push!(window.assets, "widgets")

#    l = listbox(["1", "2", "3"])
#    res = render(l, Dict())
#    show(res)

    s = Signal(1)
    l = listbox(["a", "b", "c"])

    connected_l = subscribe(s, l)

    map(s) do x
        println(x)

        connected_l
    end
end
