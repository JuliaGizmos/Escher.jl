blub = "A quick brown fox jumped over the lazy dog."

a, b, c, d = Any[
[
   normal,
   italic,
   uppercase,
 ], [
   tiny,
   medium,
   big,
   huge,
  ], [
   serif,
   sansserif,
 ], [
   thin,
   extralight,
   light,
   book,
   mediumweight,
   semibold,
   bold,
   heavy,
   fat
  ]
]

desc(p, q, r, s) =
    font(p, q, r, s)(blub)

boxes = [desc(p, q, r, s) for p=a, q=b, r=c, s=d]
main = vbox(boxes) |> pad(1cm)
