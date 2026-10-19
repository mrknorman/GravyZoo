// The review's shared table style and grade badges, imported by the review and by its generated runtime tables.
#let gr-c = box(fill: rgb("#d9eed9"), inset: (x: 2pt, y: 1pt), radius: 1.5pt, text(size: 6pt, "comparable"))
#let gr-k = box(fill: rgb("#f6ead2"), inset: (x: 2pt, y: 1pt), radius: 1.5pt, text(size: 6pt, "conditional"))
#let gr-n = box(fill: rgb("#ececec"), inset: (x: 2pt, y: 1pt), radius: 1.5pt, text(size: 6pt, "not comparable"))
#let pend = text(fill: rgb("#9a5b00"), style: "italic", "pending")
#let callout(title, body) = block(width: 100%, fill: rgb("#f2f6fb"), stroke: (left: 2.2pt + rgb("#3a6ea5")), inset: (x: 8pt, y: 6pt), radius: 1.5pt, breakable: true)[#text(weight: "bold", title) #linebreak() #body]
#let tbl(..args) = { set text(size: 6.6pt); set par(justify: false, leading: 0.45em); table(stroke: 0.35pt + luma(185), inset: (x: 3pt, y: 2.4pt), ..args) }
// A model's key in the tables' first column, with its citation.
#let keycell(k) = [#text(font: "DejaVu Sans Mono", size: 6.2pt, k) #cite(label(k))]
