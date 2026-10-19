// symbols.typ: every symbol, one per page, for review and for hand editing as SVG.
//
//   typst compile --format svg symbols.typ 'symbols/{0p}.svg'
//
// Order: the `SYMBOLS` keys, then the `DIAMOND_MARKS` keys, then the input chevron.

#import "nndiagram.typ": SYMBOLS, DIAMOND_MARKS, CHEVRON, PAPER, diamond, chevron

#set page(width: auto, height: auto, margin: 6pt, fill: PAPER)

#let sheet(g) = box(width: (g.x1 - g.x0) * 1pt, height: 2 * g.hh * 1pt,
  place(top + left, dx: -g.x0 * 1pt, dy: g.hh * 1pt, g.body))

#(SYMBOLS.values().map(f => sheet(f())) + DIAMOND_MARKS.keys().map(m => sheet(diamond(m)))
  + (box(width: CHEVRON * 1pt, height: CHEVRON * 1pt, place(top + left, dx: CHEVRON / 2 * 1pt, chevron(0.0))),)
).join(pagebreak())
