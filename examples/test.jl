using Canvas

a,b,c,d = map(h1, ["a", "b", "c", "d"])
tiles = flow(down,
    [flow(right, [a, b]),
    flow(left, [c, d])])

main = flow(down, [
    h1("The Old Man and The Sea"),
    h2("Chapter 1"),
    p("He was an old man who fished alone in a skiff in the Gulf Stream and he had gone
eighty-four days now without taking a fish. In the first forty days a boy had been with him.
But after forty days without a fish the boy’s parents had told him that the old man was
now definitely and finally salao, which is the worst form of unlucky, and the boy had gone
at their orders in another boat which caught three good fish the first week. It made the
boy sad to see the old man come in each day with his skiff empty and he always went
down to help him carry either the coiled lines or the gaff and harpoon and the sail that
was furled around the mast. The sail was patched with flour sacks and, furled, it looked
like the flag of permanent defeat."),
    p("The old man was thin and gaunt with deep wrinkles in the back of his neck. The
brown blotches of the benevolent skin cancer the sun brings from its [9] reflection on the
tropic sea were on his cheeks. The blotches ran well down the sides of his face and his
hands had the deep-creased scars from handling heavy fish on the cords. But none of
these scars were fresh. They were as old as erosions in a fishless desert. "),
    h2("Another second heading"),
    p("A series of sentences that revolve around a specific topic make a paragraph."),
    h3("Sub Sub heading here"),
    p("One more paragraph")]) |> pad(10vmin)

