
function main(window)
    push!(window.assets, "icons")
    push!(window.assets, "layout2")

    inp = Input(1)
    t, p = wire(tabs(["a","b","c"]), pages(["X","Y","Z"]), :tabs, :selected)

    m = menu(["m1", submenu("m2", ["m2.1", "m2.2"]), menuitem("m3", disabled=true),
      "m4"])
    
    mnu_sig = Input(0)
    submnu_sig = Input(0)
    vbox(
        icon("face"),
        iconbutton("face"),
        dropdownmenu("Dropdown Label", m) >>> mnu_sig,
        t |> fillcolor("#f1f1f1"), p,
        m >>> mnu_sig,
        hbox("Menu selection: ", lift(string, mnu_sig)),
        hbox("Submenu selection: ", submnu_sig),
    ) |> packacross(center)
end
