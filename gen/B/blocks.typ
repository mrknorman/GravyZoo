// blocks.typ: every collapsed-block icon (schema v2), for review.
//
//   typst compile blocks.typ blocks.png               (one sheet, each icon with its kind)
//   typst compile --input pages=1 --format svg blocks.typ 'blocks/{0p}.svg'   (one per page)

#import "nndiagram.typ": BLOCK_KINDS, PAPER, FONT, label

#set page(width: auto, height: auto, margin: 10pt, fill: PAPER)
#set text(font: FONT, size: 8pt)

#let icon(kind) = context {
  let g = (BLOCK_KINDS.at(kind))(if kind == "generic" { "Generic Block" } else { kind })
  box(width: (g.x1 - g.x0) * 1pt, height: 2 * g.hh * 1pt, place(top + left, dx: -g.x0 * 1pt, dy: g.hh * 1pt, g.body))
}

#if "pages" in sys.inputs {
  BLOCK_KINDS.keys().map(icon).join(pagebreak())
} else {
  grid(columns: 5, column-gutter: 18pt, row-gutter: 14pt, align: center + bottom,
    ..BLOCK_KINDS.keys().map(k => stack(spacing: 6pt, icon(k), raw(k))))
}
