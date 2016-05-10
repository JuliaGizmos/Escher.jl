function main(window)
    push!(window.assets, "jsonmirror")
    slideshow([
    	plaintext("Look at the souce code to see js/console help"),
	jsonmirror("{metadata:{ a: 'meta1'}}, data:[1,2,3,4,5]}", name="asdd", id="idx-333")
    ])
end
