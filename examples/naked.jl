function main(window)
    push!(window.assets, "naked")
    slideshow([
    	plaintext("Look at the souce code to see js/console help"),
	naked("<script>alert('hi');</script>")
    ])
end
