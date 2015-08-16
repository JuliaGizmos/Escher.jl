function main(window)
    push!(window.assets, "widgets")

    # Button
    btn_inp = Input{Escher.MouseButton}(leftbutton)
    bt = hbox(
        button("Click") >>> btn_inp,
        hskip(1em), "Clicks: ", hskip(1em), foldl((x, _) -> x + 1, 0, btn_inp)
    ) |> packacross(center)

    # Checkbox
    cbox_inp = Input(false)
    cbx = consume(cbox_inp) do x
        hbox(
            checkbox(x, "Label", disabled=false) >>> cbox_inp, hskip(1em),
            addinterpreter(!, checkbox(!x, "Label", disabled=false)) >>> cbox_inp,
        )
    end

    # Toggle button
    tb_inp = Input(false)
    tb = consume(tb_inp) do x
        hbox(
            togglebutton(x, disabled=false) >>> tb_inp, hskip(1em),
            addinterpreter(!, togglebutton(!x, disabled=false)) >>> tb_inp,
        )
    end

    # Slider
    sl_inp = Input(1)
    foo(x) = round(sqrt(x))
    sl = consume(sl_inp) do x
        hbox(
            slider(1:10, value=x) >>> sl_inp,
            addinterpreter(foo, slider(1:100, value=x^2)) >>> sl_inp,
        )
    end

    tx_input = Input("")
    tx = consume(tx_input) do x
        vbox(
            textinput(x, pattern="[a-Z]+", minlength=2, charcounter=true, maxlength=20, error="Letters only!", label="Label") >>> tx_input,
            textinput(x, multiline=true, minlength=2, charcounter=true, maxlength=20, error="Letters only!", label="Label") >>> tx_input,
        )
    end

    rb_inp = Input("x")
    rb = consume(rb_inp) do x
        vbox(
        radiogroup([
            radio("x", "X"),
            radio("y", "Y"),
        ], selected=x) >>> rb_inp,
        radiogroup([
            radio("x", "X"),
            radio("y", "Y"),
        ], selected=x) >>> rb_inp,
        )
    end

    page = vbox(
        title(2, "widget sampler"),
        vskip(1em),
        vskip(1em),
        bt,
        vskip(1em),
        sl,
        vskip(1em),
        cbx,
        vskip(1em),
        tb,
        tx,
        rb,
        consume(x -> Escher.spinner(x), cbox_inp),
        consume(x -> progress(x, secondaryprogress=x), sl_inp),
        vskip(2em),
        consume(x -> container(5em, 5em) |> paper(floor(x/2)), sl_inp),
    ) |> packacross(center) |> pad(2em)

end
