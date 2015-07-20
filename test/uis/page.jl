function main(window)
    push!(window.assets,"layout2")
    A = vbox("Hello, world!"|>
             pad(1em)|>
             fillcolor("#006699"),
             "Howdy!"|>
             pad(1em)|>
             fillcolor("#669933")
             )
    pages([A])
end
