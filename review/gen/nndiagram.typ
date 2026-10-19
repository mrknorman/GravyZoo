// nndiagram.typ: the owner's network-diagram style (style-spec.md), in native Typst only.
//
//   typst compile --root / --input spec=/abs/path/net.json nndiagram.typ net.png
//
// Lengths are floats in points at the deck's reference scale (a layer block is 50 x 25.5); y grows
// downward. A symbol is a glyph: (x0, x1, hh, body), its horizontal extent, half-height, and drawing
// about (0, 0). The layout engine (`diagram`) places glyphs, then lines, diamonds and the table.

#let INK = black
#let PAPER = white
#let FONT = ("Avenir LT Std", "Avenir")
#let BOOK = 350
#let MEDIUM = 600

// --- reference geometry (style-spec.md (a) and (b)) --------------------------------------------
#let SPINE = 4.0
#let BLOCK = (w: 50.0, h: 25.5, r: 5.5, lw: 5.0)   // r: 4.25 in the deck; the figures export rounder
#let ROW = 34.4
#let DIAMOND = (side: 14.9, lw: 5.25, glyph: 3.0, offset: 46.15, pitch: 29.3)
#let POOL = (w: 39.7, h: 20.9, inset: 10.63)
#let GPOOL = (w: 72.0, h: 36.0, rows: 1.35, middle: 0.68, inner: 0.62)
#let CIRCLE = (d: 25.4, lw: 5.0, mark: 4.0, halo: 3.5, concat: 0.37)
#let CHEVRON = 18.8
#let STUB = 11.1
#let TERMINAL = (dx: 7.9, d: 8.6, lw: 3.0)
#let LOOP = (lw: 6.0, r: 11.0, dx: 83.0, gap: 0.4, clear: 12.0)
#let ENCLOSE = (w: 197.3, r: 21.5)
#let ARROW = (w: 14.0, h: 17.0)
#let PE = (dx: 56.0, d: 27.0)
#let SHORTCUT = (w: 30.0, h: 15.3, lw: 3.0, side: 16.0)
#let TABLE = (header: 10, type: 10, value: 13, gap: 8.0, header-min: 28.0, header-pad: 12.0, type-w: 68.0, value-w: 58.0, rule: 1.0)

// --- drawing primitives -------------------------------------------------------------------------
#let pt2(p) = (p.at(0) * 1pt, p.at(1) * 1pt)
#let ink(w, join: "miter") = (paint: INK, thickness: w * 1pt, cap: "butt", join: join)
#let at(x, y, c) = place(top + left, dx: x * 1pt, dy: y * 1pt, c)
#let glyph(hw, hh, x0: none, ..parts) = (
  x0: if x0 == none { -hw } else { x0 }, x1: hw, hh: hh,
  body: box(width: 0pt, height: 0pt, parts.pos().join()),
)
#let poly(pts, fill: INK, lw: 0) = place(top + left, polygon(
  fill: fill, stroke: if lw > 0 { ink(lw) } else { none }, ..pts.map(pt2)))
#let polyline(pts, lw, join: "miter") = place(top + left, curve(
  stroke: ink(lw, join: join), curve.move(pt2(pts.first())), ..pts.slice(1).map(p => curve.line(pt2(p)))))
#let disc(x, y, r, fill: INK, lw: 0) = at(x - r, y - r, circle(
  radius: r * 1pt, fill: fill, stroke: if lw > 0 { ink(lw) } else { none }))
#let rrect(w, h, r, fill: none, lw: 0) = at(-w / 2, -h / 2, rect(
  width: w * 1pt, height: h * 1pt, radius: r * 1pt, fill: fill, stroke: if lw > 0 { ink(lw) } else { none }))
// content clipped to a centred rounded rectangle; `body` uses the rectangle's own frame (0..w, 0..h)
#let clipped(w, h, r, body) = at(-w / 2, -h / 2, box(
  width: w * 1pt, height: h * 1pt, radius: r * 1pt, clip: true, fill: PAPER, body))

// An open polyline whose interior corners are rounded with radius r (orthogonal routing).
#let rounded(pts, r, lw) = {
  let segs = (curve.move(pt2(pts.first())),)
  for i in range(1, pts.len() - 1) {
    let (a, b, c) = (pts.at(i - 1), pts.at(i), pts.at(i + 1))
    let len(p, q) = calc.sqrt(calc.pow(q.at(0) - p.at(0), 2) + calc.pow(q.at(1) - p.at(1), 2))
    let rr = calc.min(r, len(a, b) / 2, len(b, c) / 2)
    let towards(p, q, d) = (q.at(0) + (p.at(0) - q.at(0)) * d / len(p, q), q.at(1) + (p.at(1) - q.at(1)) * d / len(p, q))
    segs.push(curve.line(pt2(towards(a, b, rr))))
    segs.push(curve.quad(pt2(b), pt2(towards(c, b, rr))))
  }
  segs.push(curve.line(pt2(pts.last())))
  place(top + left, curve(stroke: ink(lw), ..segs))
}

// A filled chevron arrowhead, its tip at (x, y), pointing along (dx, dy), one of the four axes.
#let arrowhead(x, y, dir, w: ARROW.w, h: ARROW.h) = {
  let n = w / 2
  let local = ((-w, -h / 2), (-w + n, -h / 2), (0, 0), (-w + n, h / 2), (-w, h / 2), (-n, 0))
  let (dx, dy) = dir
  poly(local.map(((px, py)) => (x + px * dx - py * dy, y + px * dy + py * dx)))
}

// --- layer blocks -----------------------------------------------------------------------------
#let corner(w, h) = BLOCK.r * calc.min(w, h) / BLOCK.h

#let dense(w: BLOCK.w, h: BLOCK.h, lw: BLOCK.lw, fill: INK) = glyph(
  w / 2 + lw / 2, h / 2 + lw / 2, rrect(w, h, corner(w, h), fill: fill, lw: lw))

// Three rows of three V bands (the deck's chevron, adj 78187, 0.75 pt outline). The deck's V is
// 15.1 x 13.4; the thesis figures export adjacent Vs meeting at their peaks, 16.6 x 12.0 with a 3.2
// band, so each row reads as one continuous, open zigzag.
#let zigzag(w, h, up: false) = {
  let (sx, sy) = (w / BLOCK.w, h / BLOCK.h)
  let (cw, ch, band) = (16.6 * sx, 12.0 * sy, 3.2 * sy)
  let v = ((0, 0), (0, band), (cw / 2, ch), (cw, band), (cw, 0), (cw / 2, ch - band))
  for j in range(3) {
    for k in range(3) {
      let (ox, oy) = ((0.1 + 16.6 * k) * sx, (0.85 + 5.9 * j) * sy)
      let pts = v.map(((px, py)) => (ox + px, if up { h - oy - py } else { oy + py }))
      place(top + left, polygon(fill: INK, stroke: ink(0.75 * sy), ..pts.map(pt2)))
    }
  }
}

#let conv(w: BLOCK.w, h: BLOCK.h, lw: BLOCK.lw, up: false) = glyph(
  w / 2 + lw / 2, h / 2 + lw / 2,
  clipped(w, h, corner(w, h), zigzag(w, h, up: up)), rrect(w, h, corner(w, h), lw: lw))

// The deck's brace picture, traced as (across, along) with the cusp toward +across. The trace is
// slightly lopsided, so its left half is mirrored about the cusp, and the result is normalised: the
// tips span along 0..1 and tip to cusp spans across 0..1, so a brace's box is exactly its ink.
#let BRACE = {
  let pts = json("brace_outline.json").points
  let cusp = pts.fold(pts.first(), (a, p) => if p.at(0) > a.at(0) { p } else { a })
  let c = cusp.at(1)
  // the left half: from the notch over the cusp, round the left tip, back down to the cusp
  let back = pts.len() - 1 - pts.rev().position(p => p.at(1) > c)
  let half = pts.slice(back + 1) + pts.slice(1, pts.position(p => p == cusp) + 1)
  half.first() = (half.first().at(0), c)
  let whole = half + half.rev().slice(1, -1).map(((a, b)) => (a, 2 * c - b))
  let (a0, a1) = (calc.min(..whole.map(p => p.at(0))), cusp.at(0))
  let b0 = calc.min(..whole.map(p => p.at(1)))
  whole.map(((a, b)) => ((a - a0) / (a1 - a0), (b - b0) / (2 * (c - b0))))
}
// a brace w wide whose tips are at y0 and whose cusp, centred on cx, is at y0 + h
#let brace(cx, y0, w, h) = poly(BRACE.map(((a, b)) => (cx - w / 2 + b * w, y0 + a * h)))

// Multi-head attention (four stacked braces) or a single head (one brace). The braces span the
// block's interior, tip to tip between the outline's inner edges, and the lowest brace's cusp meets
// the lower wall's inner edge. Four fill the interior, the top brace's tips in its upper corners; one
// keeps the deck's tip height and stretches down to the wall.
#let attention(heads: 4) = {
  let (w, h, lw) = (BLOCK.w, BLOCK.h, BLOCK.lw)
  let (iw, ih) = (w - lw, h - lw)
  let (bh, pitch) = if heads == 1 { (ih / 2 + 13.2 / 2, 0.0) } else {
    let k = ih / (13.65 + (heads - 1) * 4.4)       // the deck's brace and pitch, scaled to fit
    (13.65 * k, 4.4 * k)
  }
  let top = ih / 2 - bh - (heads - 1) * pitch
  glyph(w / 2 + lw / 2, h / 2 + lw / 2, rrect(w, h, BLOCK.r, fill: PAPER, lw: lw),
    ..range(heads).map(i => brace(0.0, top + i * pitch, iw, bh)))
}

// --- pooling ----------------------------------------------------------------------------------
#let trapezoid(w, h, inset, wide-top: true) = {
  let (wt, wb) = if wide-top { (w / 2, w / 2 - inset) } else { (w / 2 - inset, w / 2) }
  ((-wt, -h / 2), (wt, -h / 2), (wb, h / 2), (-wb, h / 2))
}

// The dots that fall through the pooling filter, as (x, y, r): two above, the centre one lower.
// Max pooling: two equal dots and a larger centre one, the maximum. Average pooling: small to large,
// left to right, and the centre one their mean.
#let POOL_DOTS = (
  max: ((-7.0, -3.2, 1.7), (7.0, -3.2, 1.7), (0.0, 2.6, 2.5)),
  avg: ((-7.4, -3.2, 1.3), (7.4, -3.2, 2.5), (0.0, 2.6, 1.9)),
)

// a pooling trapezoid at scale k, wide edge toward the input, holding the dots of `kind`
#let pool-body(kind, k: 1.0, up: false) = (
  poly(trapezoid(POOL.w * k, POOL.h * k, POOL.inset * k, wide-top: not up), fill: PAPER, lw: BLOCK.lw * k),
  ..(if kind == none { () } else { POOL_DOTS.at(kind) }).map(((x, y, r)) => disc(x * k, y * k, r * k)),
).join()

#let pool(kind: none, up: false) = glyph(POOL.w / 2 + BLOCK.lw, POOL.h / 2 + BLOCK.lw / 2, pool-body(kind, up: up))

// Global pooling: two hollow trapezoids round the pooling symbol, all on one centre.
#let global-pool(kind) = glyph(GPOOL.w / 2 + BLOCK.lw, GPOOL.h / 2 + BLOCK.lw / 2,
  ..((1.0, 5.0), (GPOOL.middle, 4.0)).map(((s, lw)) => poly(
    trapezoid(GPOOL.w * s, GPOOL.h * s, GPOOL.h * 0.483 * s), fill: PAPER, lw: lw)),
  pool-body(kind, k: GPOOL.inner))

// --- circles: tensor operations ---------------------------------------------------------------
#let RING_OUT = CIRCLE.d / 2 + CIRCLE.lw / 2           // outer edge of a ring
#let HALO = RING_OUT + CIRCLE.halo                      // the white knock-out round a ring

// One steep sine period, rim to rim, leaning from lower left to upper right as in the SkyWarp figure.
// Its ends run under the ring's stroke, which is drawn over them.
#let sine-mark(x, y, ri) = {
  let (c, s) = (calc.cos(64deg), calc.sin(64deg))
  polyline(range(61).map(i => -1 + i / 30).map(t => {
    let (along, across) = (t * (ri + 1.0), -0.36 * ri * calc.sin(calc.pi * t))
    (x + along * c + across * s, y - along * s + across * c)
  }), CIRCLE.mark, join: "round")
}

// One ring: `mark` in plus, times, transpose, sine. `through` carries the spine across the halo.
#let ring-at(x, y, mark: "plus", d: CIRCLE.d, halo: true, through: false) = {
  let (r, ri, m) = (d / 2, d / 2 - CIRCLE.lw / 2, CIRCLE.mark)
  let marks = (
    plus: polyline(((x - ri, y), (x + ri, y)), m) + polyline(
      if through { ((x, y - HALO), (x, y + HALO)) } else { ((x, y - ri), (x, y + ri)) }, m),
    times: {
      let k = ri / calc.sqrt(2)
      polyline(((x - k, y - k), (x + k, y + k)), m) + polyline(((x - k, y + k), (x + k, y - k)), m)
    },
    transpose: polyline(((x - ri, y - ri / 4), (x + ri, y - ri / 4)), m) + polyline(((x, y - ri / 4), (x, y + ri)), m),
    sine: sine-mark(x, y, ri),
  )
  (if halo { disc(x, y, r + CIRCLE.lw / 2 + CIRCLE.halo, fill: PAPER) }, disc(x, y, r, fill: PAPER),
   marks.at(mark), disc(x, y, r, fill: none, lw: CIRCLE.lw)).join()
}

#let ring(mark: "plus") = glyph(RING_OUT, RING_OUT, ring-at(0.0, 0.0, mark: mark, through: mark == "plus"))

// Concatenate: two interlocking circled plusses; each input enters its own ring, the output
// leaves from the rings' lower crossing.
#let concat() = {
  let (dx, r) = (CIRCLE.d * CIRCLE.concat, CIRCLE.d / 2)
  let crossing = calc.sqrt(r * r - dx * dx)
  glyph(dx + RING_OUT, RING_OUT,
    disc(-dx, 0.0, HALO, fill: PAPER), disc(dx, 0.0, HALO, fill: PAPER),
    ..(-dx, dx).map(x => ring-at(x, 0.0, halo: false) + polyline(((x, -HALO), (x, 0.0)), CIRCLE.mark)),
    polyline(((0.0, crossing), (0.0, HALO)), SPINE))
}

// Positional encoding: the sine ring feeding the add ring through an arrow.
#let positional() = {
  let (px, pr) = (-PE.dx, PE.d / 2)
  glyph(RING_OUT, RING_OUT, x0: px - pr - CIRCLE.lw / 2,
    ring-at(0.0, 0.0, through: true),
    ring-at(px, 0.0, mark: "sine", d: PE.d),
    polyline(((px + pr + CIRCLE.lw / 2, 0.0), (-RING_OUT - 12.0 / 2, 0.0)), SPINE),
    arrowhead(-RING_OUT, 0.0, (1, 0), w: 12.0, h: 14.0))
}

// --- side diamonds: activations, regularisers, normalisation -----------------------------------
// The deck's SoftMax freeform (Freeform 133), five cubic segments, in EMU, in a 12.9 x 11.0 box.
#let SOFTMAX = (((0, 963386), (378278, 896711), (756557, 830036), (938893, 710293)),
  ((938893, 710293), (1121229, 590550), (947057, 356507), (1094014, 244928)),
  ((1094014, 244928), (1240971, 133349), (1685926, 77560), (1820636, 40821)),
  ((1820636, 40821), (1955346, 4082), (1875064, 31296), (1902278, 24493)),
  ((1902278, 24493), (1929492, 17689), (1956706, 8844), (1983921, 0)))

#let s-curve(w: 12.9, h: 11.0) = {
  let f(p) = pt2((p.at(0) / 1983921 * w - w / 2, p.at(1) / 963386 * h - h / 2))
  place(top + left, curve(stroke: ink(DIAMOND.glyph, join: "round"), curve.move(f(SOFTMAX.first().first())),
    ..SOFTMAX.map(s => curve.cubic(f(s.at(1)), f(s.at(2)), f(s.at(3))))))
}

// The deck's ELU (Arc 897): an ellipse 25.8 x 21.0 centred at (-5.35, -9.55), swept 270 to 363
// degrees and turned 108.2 degrees; the diamond's interior clips it.
#let elu-curve() = {
  let (a, b, cx, cy, rot) = (12.9, 10.5, -5.35, -9.55, 108.2deg)
  let pts = range(41).map(i => 270deg + i * 93deg / 40).map(t => {
    let (ex, ey) = (a * calc.cos(t), b * calc.sin(t))
    (cx + ex * calc.cos(rot) - ey * calc.sin(rot), cy + ex * calc.sin(rot) + ey * calc.cos(rot))
  })
  polyline(pts, DIAMOND.glyph, join: "round")
}

#let target(dot) = {
  let s = DIAMOND.side
  (disc(0.0, 0.0, 0.276 * s), disc(0.0, 0.0, 0.142 * s, fill: PAPER), dot).join()
}

// Inner glyphs, drawn about the diamond's centre in its upright frame (offsets in pt, y down).
#let DIAMOND_MARKS = {
  let g = DIAMOND.glyph
  let q = DIAMOND.side / calc.sqrt(2)
  let s = DIAMOND.side
  (
    relu: polyline(((-9.35, 1.25), (0.15, 1.25)), g) + polyline(((-0.85, 1.65), (6.35, -4.95)), g),
    leaky_relu: polyline(((-9.35, 2.9), (0.15, 1.25)), g) + polyline(((-0.85, 1.65), (6.35, -4.95)), g),
    elu: elu-curve(),
    gelu: polyline(range(31).map(i => -1 + i / 15).map(t => (
      -1 + 7.5 * t, 1.5 - 6.0 * calc.max(t, 0) + 1.8 * calc.exp(-calc.pow((t + 0.25) / 0.22, 2)) * (if t < 0.2 { 1 } else { 0 }))),
      g, join: "round"),
    softmax: s-curve(),
    sigmoid: s-curve() + polyline(((-6.0, 6.2), (6.0, 6.2)), g),
    tanh: s-curve() + polyline(((-3.2, 0.0), (3.2, 0.0)), g),
    linear: polyline(((-5.5, 5.5), (5.5, -5.5)), g),
    dropout: poly(((0.0, -q), (0.0, q), (-q, 0.0))),
    batch_norm: target(disc(0.0, 0.0, 0.065 * s)),
    layer_norm: target(polyline(((-0.3 * s, 0.0), (0.3 * s, 0.0)), 1.6)),
    group_norm: target(disc(-0.06 * s, 0.0, 0.045 * s) + disc(0.06 * s, 0.0, 0.045 * s)),
    mask: poly(((-0.55 * q, -0.25 * q), (-0.15 * q, -0.25 * q), (0.0, 0.05 * q), (0.15 * q, -0.25 * q),
      (0.55 * q, -0.25 * q), (0.0, 0.5 * q))),
  )
}

// A square turned 45 degrees, white inside, its glyph under a mitred outline. Every glyph stays
// inside the outline's outer edge, so the outline does the deck's clipping.
#let diamond(mark) = {
  if mark not in DIAMOND_MARKS { panic("unknown diamond mark " + repr(mark)) }
  let q = DIAMOND.side / calc.sqrt(2)
  let corners = ((0.0, -q), (q, 0.0), (0.0, q), (-q, 0.0))
  glyph(q + DIAMOND.lw / calc.sqrt(2), q + DIAMOND.lw / calc.sqrt(2),
    poly(corners, fill: PAPER), DIAMOND_MARKS.at(mark), poly(corners, fill: none, lw: DIAMOND.lw))
}

// --- spine ends -------------------------------------------------------------------------------
#let chevron(y0) = poly(((0, 0), (0, 0.5), (0.5, 1), (1, 0.5), (1, 0), (0.5, 0.5)).map(
  ((px, py)) => ((px - 0.5) * CHEVRON, y0 + py * CHEVRON)))

// --- proposed symbols (style-spec.md (d)) -----------------------------------------------------
// A recurrent layer: a loop arrow and one bar per gate in a hollow block. The arrowhead sits on the
// arc's end, its base square to the arc's tangent there and centred on the stroke.
#let recurrent(gates) = {
  let (cx, a, b, t0, t1) = (-6.0, 7.5, 6.2, 200deg, 470deg)
  let arc = range(61).map(i => t0 + i * (t1 - t0) / 60).map(t => (cx + a * calc.cos(t), b * calc.sin(t)))
  let (ex, ey) = arc.last()
  let (tx, ty) = (-a * calc.sin(t1), b * calc.cos(t1))
  let n = calc.sqrt(tx * tx + ty * ty)
  let (ux, uy) = (tx / n, ty / n)
  let (half, len) = (3.5, 6.0)
  let d = dense(fill: PAPER)
  glyph(d.x1, d.hh, d.body, polyline(arc, 3.0),
    poly(((ex - uy * half, ey + ux * half), (ex + ux * len, ey + uy * len), (ex + uy * half, ey - ux * half))),
    ..range(gates).map(i => polyline(((9 + 5.2 * i, -6.0), (9 + 5.2 * i, 6.0)), 3.0)))
}

#let embedding() = {
  let d = dense(fill: PAPER)
  glyph(d.x1, d.hh, d.body, ..(12, 4, 16, 8).enumerate().map(((i, r)) => polyline(((-16, -7.5 + 5 * i), (r, -7.5 + 5 * i)), 2.6)))
}

// --- tensor rearrangements: a rounded square frame, the tensor above a dotted line and below it ---
#let FRAME = (side: 27.5, lw: 3.0, r: 5.5, dot: 0.75, dot-pitch: 3.0, rule: 9.0)
#let shift(x, y, c) = at(x, y, box(width: 0pt, height: 0pt, c))

#let framed(rule-y: 0.0, ..parts) = {
  let n = int(2 * FRAME.rule / FRAME.dot-pitch)
  let dots = range(n + 1).map(i => disc(-FRAME.rule + i * FRAME.dot-pitch, rule-y, FRAME.dot))
  glyph(FRAME.side / 2 + FRAME.lw / 2, FRAME.side / 2 + FRAME.lw / 2,
    rrect(FRAME.side, FRAME.side, FRAME.r, fill: PAPER, lw: FRAME.lw), ..dots, ..parts.pos())
}

// Flatten: a small layer block above, the same block flattened (same area, wider and thinner) below.
#let flatten() = {
  let (w, h) = (11.0, 11.0 * BLOCK.h / BLOCK.w)
  let (fw, fh) = (19.0, 11.0 * h / 19.0)
  framed(shift(0.0, -6.0, rrect(w, h, corner(w, h), fill: INK)), shift(0.0, 6.0, rrect(fw, fh, corner(fw, fh), fill: INK)))
}

// Whitening: a filled block above the dotted line, the same block empty below.
#let whitening() = {
  let (w, h, lw) = (16.0, 7.0, 1.6)
  framed(shift(0.0, -6.5, rrect(w, h, corner(w, h), fill: INK)),
    shift(0.0, 6.5, rrect(w - lw, h - lw, corner(w - lw, h - lw), fill: PAPER, lw: lw)))
}

// Permute: circle, square, triangle above; the same shapes reordered below.
#let permute() = {
  let shape(kind, x, y) = (
    circle: disc(x, y, 2.7),
    square: poly(((x - 2.4, y - 2.4), (x + 2.4, y - 2.4), (x + 2.4, y + 2.4), (x - 2.4, y + 2.4))),
    triangle: poly(((x, y - 3.0), (x + 3.0, y + 2.4), (x - 3.0, y + 2.4))),
  ).at(kind)
  let xs = (-7.0, 0.0, 7.0)
  framed(..("circle", "square", "triangle").zip(xs).map(((k, x)) => shape(k, x, -6.0)),
    ..("triangle", "circle", "square").zip(xs).map(((k, x)) => shape(k, x, 6.0)))
}

// Reshape: one shape cut by the dotted line, a semicircle above and the bottom half of a five-pointed
// star below, the two halves equally wide where they meet.
#let reshape() = {
  let (R, gap, y0) = (11.4, 1.6, -1.6)
  let star(k, rr) = (rr * calc.cos(90deg + 36deg * k), -rr * calc.sin(90deg + 36deg * k))
  let pts = range(10).map(k => star(k, if calc.even(k) { R } else { R * 0.382 }))
  // the star below the line through its centre: where edges 2-3 and 7-8 cross it, and the points between
  let cut(p, q) = { let t = p.at(1) / (p.at(1) - q.at(1)); p.at(0) + t * (q.at(0) - p.at(0)) }
  let (xl, xr) = (cut(pts.at(2), pts.at(3)), cut(pts.at(7), pts.at(8)))
  let lower = ((xl, 0.0),) + pts.slice(3, 8) + ((xr, 0.0),)
  let upper = range(41).map(i => 180deg * i / 40).map(t => (xr * calc.cos(t), -xr * calc.sin(t)))
  framed(rule-y: y0, poly(upper.map(((x, y)) => (x, y0 - gap + y))), poly(lower.map(((x, y)) => (x, y0 + gap + y))))
}

// The transformer block's tight frame: a 3 pt rounded outline round a layer glyph. It is also the
// frame of every collapsed block (schema v2, below).
#let BFRAME = (w: BLOCK.w + 16, h: BLOCK.h + 12, r: 9.0, lw: 3.0)
#let enframe(g) = glyph(g.x1 + 8, g.hh + 6, rrect(BFRAME.w, BFRAME.h, BFRAME.r, fill: PAPER, lw: BFRAME.lw), g.body)

#let transformer() = enframe(attention())

#let SYMBOLS = (
  conv1d: () => conv(), conv_transpose1d: () => conv(up: true),
  dense: () => dense(), whitening: whitening,
  maxpool1d: () => pool(kind: "max"), avgpool1d: () => pool(kind: "avg"), upsample1d: () => pool(up: true),
  global_avgpool1d: () => global-pool("avg"), global_maxpool1d: () => global-pool("max"),
  multi_head_attention: () => attention(), attention_head: () => attention(heads: 1),
  add: () => ring(), concatenate: () => concat(), positional_encoding: () => positional(),
  lstm: () => recurrent(3), gru: () => recurrent(2), embedding: () => embedding(),
  flatten: flatten, reshape: reshape, permute: permute,
  transformer_block: () => transformer(),
)
#let ROW_SCALE = (global_avgpool1d: GPOOL.rows, global_maxpool1d: GPOOL.rows)
#let NORM_MARK = (batch: "batch_norm", layer: "layer_norm", group: "group_norm")
#let NORM_NAME = (batch: "Batch", layer: "Layer", group: "Group")
#let ACT_NAME = (relu: "ReLU", elu: "ELU", softmax: "SoftMax", sigmoid: "Sigmoid", tanh: "Tanh",
  linear: "Linear", gelu: "GELU", leaky_relu: "Leaky ReLU")

// --- block icons (schema v2) ------------------------------------------------------------------
// A collapsed block is one icon in the transformer block's frame. A stack of one kind of layer is
// that layer's glyph, framed. A block with its own topology holds a miniature of it at 0.6 scale
// (strokes scale with it, so a miniature block's outline is the frame's 3 pt), and a block that ends
// in a merge carries the merge on its lower edge, as the enclosing residual box does.
#let MINI = 0.6
#let mini(g, x, y) = at(x, y, scale(x: MINI * 100%, y: MINI * 100%, origin: top + left, reflow: false, g.body))
#let mini-line(pts) = polyline(pts, SPINE * MINI)
#let bframe(w, h) = rrect(w, h, BFRAME.r, fill: PAPER, lw: BFRAME.lw)

// a frame h tall whose lower edge carries a miniature merge glyph `merge`, `parts` under the merge
// and `over` above it, in the frame's own coordinates; the ink is centred
#let merge-icon(h, merge, over: (), ..parts) = {
  let (top, low) = (h / 2 + BFRAME.lw / 2, h / 2 + merge.hh * MINI)
  glyph(BFRAME.w / 2 + BFRAME.lw / 2, (top + low) / 2, shift(0.0, (top - low) / 2,
    (bframe(BFRAME.w, h), ..parts.pos(), mini(merge, 0.0, h / 2), ..over).join()))
}

// Residual block: the frame is the skip, as in the enclosing residual box: a convolution inside,
// the add on the lower edge, the left edge entering it through an arrowhead.
#let residual-icon() = {
  let h = 36.0
  merge-icon(h, ring(), mini-line(((0.0, -h / 2), (0.0, h / 2))), mini(conv(), 0.0, -5.0),
    over: (arrowhead(-RING_OUT * MINI, h / 2, (1, 0), w: ARROW.w * MINI, h: ARROW.h * MINI),))
}

// Inception: three convolutions in parallel between two buses, concatenated on the lower edge.
#let inception-icon() = {
  let h = 40.0
  let (xs, yt, yc, yb) = ((-19.5, 0.0, 19.5), -15.0, -5.5, 5.0)
  let cx = CIRCLE.d * CIRCLE.concat * MINI
  let c = conv(w: 13.0, h: 12.0, lw: BFRAME.lw)
  merge-icon(h, concat(),
    mini-line(((0.0, -h / 2), (0.0, yb))),
    poly(((xs.first(), yt), (xs.last(), yt), (xs.last(), yb), (xs.first(), yb)), fill: none, lw: SPINE * MINI),
    ..(-cx, cx).map(x => mini-line(((x, yb), (x, h / 2)))),
    ..xs.map(x => at(x, yc, c.body)))
}

// Coupling layer (normalising flow): two halves side by side; one, through a small network,
// scales the other at a multiply ring.
#let coupling-icon() = {
  let (w, h) = (BFRAME.w, BFRAME.h)
  let (xl, xr, yt, yb, xn) = (-19.0, 19.0, -12.5, 12.5, -6.5)
  let ro = RING_OUT * MINI
  let net = dense(w: 12.0, h: 8.0, lw: BFRAME.lw)
  let aw = ARROW.w * MINI
  glyph(w / 2 + BFRAME.lw / 2, h / 2 + BFRAME.lw / 2, bframe(w, h),
    mini-line(((0.0, -h / 2), (0.0, yt))), mini-line(((0.0, yb), (0.0, h / 2))),
    poly(((xl, yt), (xr, yt), (xr, yb), (xl, yb)), fill: none, lw: SPINE * MINI),
    mini-line(((xl, 0.0), (xr - ro - aw / 2, 0.0))),
    at(xn, 0.0, net.body),
    mini(ring(mark: "times"), xr, 0.0),
    arrowhead(xr - ro, 0.0, (1, 0), w: aw, h: ARROW.h * MINI))
}

// Two miniature glyphs on a spine (a U-Net stage: convolution then pooling, or upsampling then
// convolution), spaced evenly in the frame.
#let stack-icon(a, b) = {
  let h = 42.0
  let inner = h - BFRAME.lw
  let (ha, hb) = (2 * a.hh * MINI, 2 * b.hh * MINI)
  let gap = (inner - ha - hb) / 3
  let ya = -inner / 2 + gap + ha / 2
  let yb = ya + ha / 2 + gap + hb / 2
  glyph(BFRAME.w / 2 + BFRAME.lw / 2, h / 2 + BFRAME.lw / 2, bframe(BFRAME.w, h),
    mini-line(((0.0, -h / 2), (0.0, h / 2))), mini(a, 0.0, ya), mini(b, 0.0, yb))
}

// Autoencoder halves: solid layer bars narrowing to the code (encoder) or widening from it (decoder).
#let funnel-icon(widths) = {
  let n = widths.len()
  let (bh, lw) = if n <= 3 { (6.0, 2.0) } else { (3.6, 1.6) }
  let pitch = (BFRAME.h - BFRAME.lw - 6.0 - bh - lw) / (n - 1)
  glyph(BFRAME.w / 2 + BFRAME.lw / 2, BFRAME.h / 2 + BFRAME.lw / 2, bframe(BFRAME.w, BFRAME.h),
    mini-line(((0.0, -BFRAME.h / 2), (0.0, BFRAME.h / 2))),
    ..widths.enumerate().map(((i, w)) => at(0.0, (i - (n - 1) / 2) * pitch, dense(w: w, h: bh, lw: lw).body)))
}

// --- the layout engine ------------------------------------------------------------------------
// An item is (z, bb: (x0, y0, x1, y1), body) with its body drawn in diagram coordinates.
#let Z = (box: -1, loop: 0, spine: 1, glyph: 2, ring: 3, arrow: 4, side: 5, text: 6)
#let put(z, x, y, g) = (z: z, bb: (x + g.x0, y - g.hh, x + g.x1, y + g.hh), body: at(x, y, g.body))
#let line-item(z, pts, lw, r: 0.0) = (
  z: z, body: if r > 0 { rounded(pts, r, lw) } else { polyline(pts, lw) },
  bb: (calc.min(..pts.map(p => p.at(0))) - lw / 2, calc.min(..pts.map(p => p.at(1))) - lw / 2,
       calc.max(..pts.map(p => p.at(0))) + lw / 2, calc.max(..pts.map(p => p.at(1))) + lw / 2))
// text centred on (x, y), or with its left / right edge at x; `width` wraps it (needs context)
#let label(x, y, s, size, weight: BOOK, anchor: "center", width: none) = {
  let body = {
    set par(leading: 0.32em, spacing: 0pt)
    set text(font: FONT, size: size * 1pt, weight: weight)
    align(center, s.split("\n").join(linebreak()))
  }
  let m = measure(if width == none { body } else { box(width: width * 1pt, body) })
  let (w, h) = (m.width / 1pt, m.height / 1pt)
  let x0 = if anchor == "left" { x } else if anchor == "right" { x - w } else { x - w / 2 }
  (z: Z.text, bb: (x0, y - h / 2, x0 + w, y + h / 2), body: at(x0, y - h / 2, box(width: w * 1pt, body)))
}

// The generic block: its label in the frame, the frame widened to fit (needs context).
#let generic-icon(name) = {
  let t = label(0.0, 0.0, name, 10, weight: MEDIUM)
  let w = calc.max(BFRAME.w, t.bb.at(2) - t.bb.at(0) + 16)
  glyph(w / 2 + BFRAME.lw / 2, BFRAME.h / 2 + BFRAME.lw / 2, bframe(w, BFRAME.h), t.body)
}

// Block kinds and their collapsed icons, each a function of the block's label.
#let BLOCK_KINDS = (
  transformer_encoder: _ => transformer(),
  residual_block: _ => residual-icon(),
  inception: _ => inception-icon(),
  conv_stage: _ => enframe(conv()),
  mlp_head: _ => enframe(dense()),
  lstm_stack: _ => enframe(recurrent(3)),
  gru_stack: _ => enframe(recurrent(2)),
  unet_down: _ => stack-icon(conv(), pool(kind: "max")),
  unet_up: _ => stack-icon(pool(up: true), conv()),
  autoencoder_encoder: _ => funnel-icon((46.0, 32.0, 18.0)),
  autoencoder_decoder: _ => funnel-icon((18.0, 32.0, 46.0)),
  autoencoder: _ => funnel-icon((46.0, 32.0, 18.0, 32.0, 46.0)),
  flow_coupling: _ => coupling-icon(),
  generic: generic-icon,
)

// Standard table columns (schema v2): a spec names them by key so that two models' tables compare.
#let STD_COLUMNS = (
  type: (key: "type", header: "Type"),
  filters: (key: "filters", header: "Num Filters /\nNeurons /\nHeads", from: ("filters", "units", "heads"), header_size: 8),
  size: (key: "size", header: "Filter / Pool\n/ Head Size", from: ("kernel", "pool", "head_size"), header_size: 8),
  stride: (key: "stride", header: "Stride"),
  dilation: (key: "dilation", header: "Dilation"),
  dims: (key: "dims", header: "Hidden\nDimensions", from: ("dims", "hidden"), header_size: 8),
  norm: (key: "norm", header: "Norm"),
  activation: (key: "activation", header: "Activation\nFunction"),
  dropout: (key: "dropout", header: "Dropout"),
)

// An expanded block's dash-dot box (the CrossWave sub-network box): the band above its first row
// holds its label, the foot below its last row closes it; parallel lanes start below a split gap.
#let BOX = (lw: 2.0, r: 10.0, pad: 10.0, inset: 4.0, band: 0.8, foot: 0.5, split: 0.5, label: 9,
  dash: (8pt, 3pt, 2pt, 3pt))
#let BLOCK_GAP = 8.0   // the gap a collapsed block leaves above and below its icon

// --- schema v2: the plan -----------------------------------------------------------------------
// `plan` turns a spec's tree of nodes and blocks into what the layout draws: the visible nodes in
// drawing order, a layout tree (nodes, parallel groups of lanes, and the open and close of each
// expanded block), and every edge resolved to visible nodes. A collapsed block is one node that
// stands for all it holds; an expanded one is replaced by its children. A v1 spec plans to itself.
#let plan(spec, expand) = {
  let opens(n) = n.type == "block" and (expand == "all" or (type(expand) == array and n.id in expand)
    or n.at("collapsed", default: true) == false or n.children.nodes.any(opens))
  let hide(nodes, owner, st) = {
    for c in nodes {
      st.owner.insert(c.id, owner)
      if c.type == "block" { st = hide(c.children.nodes, owner, st) }
    }
    st
  }
  // one level (the spec, a block's children, or one lane); returns the state, the level's layout
  // items and the node(s) the next node follows
  let walk(level, ctx, st) = {
    let home = level.at("home", default: "main")
    let lane-of(n) = n.at("branch", default: "main")
    let branches = level.at("branches", default: ())
    let items = ()
    let prev = ctx.prev
    let grouped = false
    for n in level.nodes {
      if lane-of(n) != home {
        // the level's lanes, laid side by side where the first of their nodes stands
        if grouped { continue }
        grouped = true
        let (lanes, ends) = ((), ())
        for b in branches {
          let sub = (nodes: level.nodes.filter(m => lane-of(m) == b.id), home: b.id)
          let (st2, li, last) = walk(sub, ctx + (lane: b.id, prev: prev), st)
          st = st2
          lanes.push((id: b.id, side: b.at("side", default: none), items: li))
          ends.push(last)
        }
        let b0 = branches.first()
        items.push((kind: "group", lanes: lanes, split: prev != none,
          sep: b0.at("separation", default: 100.0), gap: b0.at("merge_gap_rows", default: 1.0)))
        prev = ends.flatten()
        continue
      }
      if opens(n) {
        let anc = ctx.anc + (n.id,)
        st.anc.insert(n.id, anc)
        st.blocks.push((id: n.id, kind: n.kind, label: n.label, expanded: true, parent: ctx.of, depth: ctx.anc.len()))
        let mark = st.nodes.len()
        items.push((kind: "open", id: n.id))
        let (st2, ci, last) = walk(n.children, ctx + (of: n.id, anc: anc, prev: prev, entry: prev), st)
        st = st2
        items += ci
        items.push((kind: "close", id: n.id))
        st.owner.insert(n.id, n.id)
        st.first.insert(n.id, st.nodes.at(mark).id)
        st.exit.insert(n.id, last)
        st.boxes.push((id: n.id, label: n.label, depth: anc.len()))
        if n.at("repeat", default: 1) > 1 {
          st.repeats.push((first: n.id, last: n.id, times: n.repeat, label: n.at("repeat_label", default: n.label)))
        }
        prev = last
        continue
      }
      if n.type == "block" {
        st = hide(n.children.nodes, n.id, st)
        st.blocks.push((id: n.id, kind: n.kind, label: n.label, expanded: false, parent: ctx.of, depth: ctx.anc.len()))
        if n.at("repeat", default: 1) > 1 {
          st.repeats.push((first: n.id, last: n.id, times: n.repeat, label: n.at("repeat_label", default: "")))
        }
      }
      st.nodes.push(n + (branch: ctx.lane))
      st.owner.insert(n.id, n.id)
      st.anc.insert(n.id, ctx.anc)
      st.inputs.insert(n.id, n.at("inputs", default: if prev == none { () } else if type(prev) == array { prev } else { (prev,) }))
      items.push((kind: "node", id: n.id))
      if not n.at("on_skip", default: false) { prev = n.id }
    }
    for r in level.at("residuals", default: ()) {
      st.residuals.push(r + (of: ctx.of, entry: "from" not in r, from: r.at("from", default: ctx.entry)))
    }
    st.repeats += level.at("repeats", default: ())
    (st, items, prev)
  }
  let st0 = (nodes: (), inputs: (:), owner: (:), anc: (:), residuals: (), repeats: (), boxes: (), blocks: (),
    first: (:), exit: (:))
  let (st, items, _) = walk(spec, (of: none, anc: (), lane: "main", prev: none, entry: none), st0)
  if type(expand) == array {
    for id in expand { if id not in st.anc or st.blocks.find(b => b.id == id) == none { panic("expand: no block " + repr(id)) } }
  }
  // an id resolves to the visible node that stands for it: itself, its collapsed block, or the
  // last node of its expanded block
  let visible(id) = {
    if id not in st.owner { panic("unknown node id " + repr(id)) }
    let o = st.owner.at(id)
    if o in st.exit { st.exit.at(o) } else { o }
  }
  let single(id, what) = {
    if id == none or type(id) == array { panic(what + ": the block's entry must be one node") }
    let v = visible(id)
    if type(v) == array { panic(what + ": " + repr(id) + " ends in parallel lanes; end it with a merge") }
    v
  }
  (
    nodes: st.nodes, items: items, anc: st.anc, boxes: st.boxes, blocks: st.blocks,
    inputs: st.inputs.pairs().map(((k, v)) => (k, v.map(visible).flatten().dedup())).to-dict(),
    residuals: st.residuals.map(r => r + (from: single(r.from, "residual to " + repr(r.to)), to: single(r.to, "residual"))
      + if "projection" in r { (projection: single(r.projection, "projection")) } else { (:) }).filter(r => r.from != r.to),
    repeats: st.repeats.map(r => r + (first: if r.first in st.first { st.first.at(r.first) } else { single(r.first, "repeat") },
      last: single(r.last, "repeat"))),
  )
}

#let diagram(spec, expand: ()) = context {
  if "diagram" in spec and spec.diagram == none {
    panic("no diagram for " + spec.at("key", default: "?") + ": " + spec.at("reason", default: ""))
  }
  let v2 = spec.at("format", default: "").starts-with("nn-diagram/2")
  let p = plan(spec, expand)
  let nodes = p.nodes
  let ids = nodes.map(n => n.id)
  let by = nodes.fold((:), (d, n) => { d.insert(n.id, n); d })
  let get(n, k, default: none) = n.at(k, default: default)
  let branch(n) = get(n, "branch", default: "main")
  let skip(n) = get(n, "on_skip", default: false)
  let drawn(n) = n.type not in ("input", "output")
  for n in nodes.filter(drawn) {
    if n.type == "block" {
      if n.kind not in BLOCK_KINDS { panic("unknown block kind " + repr(n.kind) + " (" + n.id + ")") }
    } else if n.type not in SYMBOLS { panic("unknown node type " + repr(n.type) + " (" + n.id + ")") }
  }
  let glyphs = nodes.filter(drawn).fold((:), (d, n) => {
    d.insert(n.id, if n.type == "block" { BLOCK_KINDS.at(n.kind)(n.label) }
      else if skip(n) { conv(w: SHORTCUT.w, h: SHORTCUT.h, lw: SHORTCUT.lw) } else { SYMBOLS.at(n.type)() })
    d
  })
  let pitch(n) = if n.type == "block" and "rows" not in n { calc.max(ROW, 2 * glyphs.at(n.id).hh + BLOCK_GAP) } else {
    ROW_SCALE.at(n.type, default: 1.0) * ROW * get(n, "rows", default: 1.0) }
  let inputs(n) = p.inputs.at(n.id)
  let residuals = p.residuals
  let next-id(id) = ids.at(ids.position(i => i == id) + 1)
  // the first layer inside a skip drops, so the loop or the box's top edge clears its diamonds; a
  // loop from an expanded block's entry forks in the block's band instead, above its first layer
  let banded(r) = r.entry and r.of != none and get(r, "style", default: "loop") == "loop"
  let skip-first = residuals.filter(r => not banded(r)).map(r => next-id(r.from))
  let outward(n) = (get(n, "activation"), if get(n, "dropout") != none { "dropout" },
    if get(n, "mask", default: false) { "mask" }).filter(v => v != none)
  let placement = get(spec.table, "placement", default: "left")

  // rows: a sequence stacks top to bottom; a parallel group sets its lanes side by side, spaced to
  // clear the diamonds and glyphs that face each other. With an outer table each side's lanes share
  // rows with the other side's, and the branches' last glyphs share a row; lanes that share a table
  // stack, so every row keeps its own table line.
  let column(k) = if k > 0 { DIAMOND.offset + 2 * DIAMOND.pitch / 3 + DIAMOND.pitch * (k - 1) } else { 0.0 }
  let first-node(items) = items.find(i => i.kind == "node" and drawn(by.at(i.id)))
  let lay(items, x, y, s, acc) = {
    for it in items {
      if it.kind == "node" {
        let n = by.at(it.id)
        if n.type == "input" { acc.pos.insert(n.id, (x: x, y: y, side: s)); continue }
        if not drawn(n) { continue }
        let top0 = y
        if n.id in skip-first { y += LOOP.gap * ROW }
        acc.pos.insert(n.id, (x: x, y: y + pitch(n) / 2, side: s, top: top0))
        y += pitch(n)
      } else if it.kind == "open" {
        acc.marks.insert(it.id, (top: y))
        y += BOX.band * ROW
      } else if it.kind == "close" {
        y += BOX.foot * ROW
        acc.marks.insert(it.id, acc.marks.at(it.id) + (bottom: y))
      } else {
        let order = it.lanes.sorted(key: l => if l.side == "left" { 0 } else if l.side == "right" { 2 } else { 1 })
        let k = order.len()
        let lanes = order.enumerate().map(((i, l)) => l + (side: if l.side == "left" { -1 } else if l.side == "right" { 1 }
          else if 2 * i < k - 1 { -1 } else { 1 }))
        let members(l) = nodes.filter(n => branch(n) == l.id and drawn(n))
        let face(l, dir) = calc.max(0, ..members(l).map(n => if l.side == dir { outward(n).len() } else if get(n, "norm") != none { 1 } else { 0 }))
        // a lane that holds an expanded block also clears its box on the inner side
        let boxed(l) = if l.items.any(i => i.kind == "open") { BOX.pad + BOX.lw } else { 0.0 }
        let width(l) = calc.max(0.0, ..members(l).map(n => glyphs.at(n.id).x1)) + boxed(l)
        let gaps = range(k - 1).map(i => {
          let (a, b) = (lanes.at(i), lanes.at(i + 1))
          let c = calc.max(column(face(a, 1)) + boxed(a), column(face(b, -1)) + boxed(b))
          calc.max(it.sep, 2 * c, width(a) + width(b) + 12.0)
        })
        let total = gaps.sum(default: 0.0)
        let xs = range(k).map(i => x - total / 2 + gaps.slice(0, i).sum(default: 0.0))
        let stacks = if placement == "outer" {
          (lanes.enumerate().filter(((i, l)) => l.side < 0), lanes.enumerate().filter(((i, l)) => l.side > 0))
        } else { (lanes.enumerate(),) }
        let empty = (pos: (:), marks: (:), splits: (:))
        let height(i, l) = lay(l.items, xs.at(i), 0.0, l.side, empty).at(1)
        let depth = calc.max(..stacks.map(stack => stack.map(((i, l)) => height(i, l)).sum(default: 0.0)))
        let base = if it.split { y + BOX.split * ROW } else { y }
        for stack in stacks {
          let yy = base
          for (j, (i, l)) in stack.enumerate() {
            let (acc2, end) = lay(l.items, xs.at(i), yy, l.side, acc)
            acc = acc2
            let last = l.items.last()
            if j == stack.len() - 1 and last.kind == "node" and drawn(by.at(last.id)) {
              let n = by.at(last.id)
              let top = base + depth - pitch(n)
              acc.pos.insert(n.id, acc.pos.at(n.id) + (y: top + pitch(n) / 2, top: top))
            }
            let f = first-node(l.items)
            if it.split and f != none { acc.splits.insert(f.id, y + BOX.split * ROW / 2) }
            yy = end
          }
        }
        y = base + depth + ROW * it.gap
      }
    }
    (acc, y)
  }
  let (acc, bottom) = lay(p.items, 0.0, 0.0, 1, (pos: (:), marks: (:), splits: (:)))
  let pos = acc.pos
  let items = ()
  let tag(list, of) = list.map(i => i + (of: of))

  // glyphs and their side columns: activation, dropout, mask outward; normalisation mirrored
  let table = spec.table
  let cols = table.columns.map(c => if type(c) == str { STD_COLUMNS.at(c) } else { c })
  let node-items(n, pos) = {
    let (x, yn, s) = (pos.at(n.id).x, pos.at(n.id).y, pos.at(n.id).side)
    let g = glyphs.at(n.id)
    let z = if n.type in ("add", "concatenate", "positional_encoding") { Z.ring } else { Z.glyph }
    let own = (put(z, x, yn, g),)
    let base = if skip(n) { g.x1 + SHORTCUT.side } else { DIAMOND.offset }
    let out = outward(n)
    for (k, mark) in out.enumerate() {
      own.push(put(Z.side, x + s * (base + DIAMOND.pitch * k), yn, diamond(mark)))
    }
    if get(n, "norm") != none {
      let dx = if skip(n) { s * (base + DIAMOND.pitch * out.len()) } else { -s * DIAMOND.offset }
      own.push(put(Z.side, x + dx, yn, diamond(NORM_MARK.at(n.norm))))
    }
    // a block's label goes in the table's Type column, or beside it when the table has none
    let note = if n.type == "block" and not cols.any(c => c.key == "type") { n.label } else { get(n, "annotate") }
    if note != none {
      own.push(label(x + s * (g.x1 + 12), yn, note, 10, anchor: if s > 0 { "left" } else { "right" }))
    }
    tag(own, n.id)
  }
  let own = nodes.filter(n => drawn(n) and not skip(n)).fold((:), (d, n) => { d.insert(n.id, node-items(n, pos)); d })

  // residual skips: an outside loop, or an enclosing box round the whole block. A loop runs out to
  // clear what lies between its fork and its add on its side, any loop it encloses, and every
  // expanded block's box it passes.
  let side-of(r) = {
    let act = pos.at(r.to).side
    (left: -1, right: 1).at(get(r, "side", default: ""), default: if get(by.at(r.to), "activation") != none { -act } else { act })
  }
  // a skip from an expanded block's entry leaves the spine inside the block's box, under its label
  let fork-y(r) = if banded(r) { acc.marks.at(r.of).top + BOX.band * ROW - 3.0 }
    else { pos.at(r.from).y + glyphs.at(r.from).hh + 4.0 }
  let reach-of(n, s, x) = {
    let k = if pos.at(n.id).side == s { outward(n).len() } else if get(n, "norm") != none { 1 } else { 0 }
    s * (pos.at(n.id).x - x) + if k > 0 { DIAMOND.offset + DIAMOND.pitch * (k - 1) + 14.5 } else { glyphs.at(n.id).x1 }
  }
  let looping(i) = get(residuals.at(i), "style", default: "loop") != "enclose"
  let depth-of(r) = if r.of == none { 0 } else { p.anc.at(r.of).len() }

  // Skips and boxes are placed innermost first: a box encloses the skips declared inside it, and a
  // skip is placed after the boxes it may pass, which lie deeper than the level that declares it.
  let (geo, skips, boxes, framed) = ((:), (:), (:), (:))
  for d in range(calc.max(0, ..p.boxes.map(b => b.depth)), -1, step: -1) {
    let here = range(residuals.len()).filter(i => depth-of(residuals.at(i)) == d)
    for i in here.filter(looping).sorted(key: i => pos.at(residuals.at(i).to).y - fork-y(residuals.at(i))) {
      let r = residuals.at(i)
      let (x, ya, s, yf) = (pos.at(r.to).x, pos.at(r.to).y, side-of(r), fork-y(r))
      let reach = 0.0
      for n in nodes.filter(n => drawn(n) and not skip(n) and n.id != r.from and yf <= pos.at(n.id).y and pos.at(n.id).y <= ya) {
        reach = calc.max(reach, reach-of(n, s, x))
      }
      for g in geo.values() {
        if g.s == s and yf <= g.yf and g.ya <= ya { reach = calc.max(reach, s * (g.lx - x) + g.out + LOOP.lw / 2) }
      }
      for bb in boxes.values() {
        if bb.at(1) < ya and bb.at(3) > yf { reach = calc.max(reach, s * ((if s > 0 { bb.at(2) } else { bb.at(0) }) - x)) }
      }
      let lx = x + s * calc.max(LOOP.dx, reach + LOOP.clear)
      // how far the loop's own ink reaches past its line: its stroke, or a projection and its diamonds
      let out = if "projection" in r {
        let q = by.at(r.projection)
        let c = outward(q).len() + if get(q, "norm") != none { 1 } else { 0 }
        if c > 0 { glyphs.at(q.id).x1 + SHORTCUT.side + DIAMOND.pitch * (c - 1) + 14.5 } else { glyphs.at(q.id).x1 }
      } else { LOOP.lw / 2 }
      geo.insert(str(i), (s: s, lx: lx, yf: yf, ya: ya, out: out))
    }
    for i in here {
      let r = residuals.at(i)
      let (fork, add) = (r.from, r.to)
      let (x, ya) = (pos.at(add).x, pos.at(add).y)
      let reach-in = glyphs.at(add).x1
      if not looping(i) {
        let first = next-id(fork)
        let yt = pos.at(first).top + LOOP.gap * ROW / 2
        let hw = ENCLOSE.w / 2
        let tip = x - reach-in
        skips.insert(str(i), tag((line-item(Z.loop, ((x, ya), (x + hw, ya), (x + hw, yt), (x - hw, yt), (x - hw, ya),
          (tip - ARROW.w / 2, ya)), LOOP.lw, r: ENCLOSE.r),
          put(Z.arrow, tip, ya, glyph(0, 0, arrowhead(0.0, 0.0, (1, 0))))), r.of))
        continue
      }
      let (s, lx, yf) = (geo.at(str(i)).s, geo.at(str(i)).lx, geo.at(str(i)).yf)
      let tip = x + s * reach-in
      skips.insert(str(i), tag((line-item(Z.loop, ((x, yf), (lx, yf), (lx, ya), (tip + s * ARROW.w / 2, ya)), LOOP.lw, r: LOOP.r),
        put(Z.arrow, tip, ya, glyph(0, 0, arrowhead(0.0, 0.0, (-s, 0))))), r.of))
      let q = get(r, "projection")
      if q != none {
        pos.insert(q, (x: lx, y: pos.at(q).y, side: s))
        own.insert(q, node-items(by.at(q), pos))
      }
    }
    // expanded blocks: a dash-dot box round everything drawn for the block, its label inside the
    // top corner on the outer side of the spine (the right in a right-hand lane, else the left)
    for b in p.boxes.filter(b => b.depth == d) {
      let inside = (own.values() + skips.values() + framed.values()).flatten().filter(
        i => get(i, "of") != none and b.id in p.anc.at(i.of, default: ()))
      let m = acc.marks.at(b.id)
      let w = label(0.0, 0.0, b.label, BOX.label, anchor: "left").bb.at(2)
      let lead = nodes.find(n => drawn(n) and b.id in p.anc.at(n.id))
      let xs = pos.at(lead.id).x
      let right = branch(lead) != "main" and pos.at(lead.id).side > 0
      let x0 = calc.min(..inside.map(i => i.bb.at(0))) - BOX.pad
      let x1 = calc.max(..inside.map(i => i.bb.at(2))) + BOX.pad
      if right { x1 = calc.max(x1, xs + SPINE / 2 + 14.0 + w) } else { x0 = calc.min(x0, xs - SPINE / 2 - 14.0 - w) }
      let y0 = m.top + BOX.inset
      let y1 = calc.max(m.bottom - BOX.inset, calc.max(..inside.map(i => i.bb.at(3))) + 4.0)
      let h = BOX.lw / 2
      framed.insert(b.id, (
        (z: Z.box, of: b.id, bb: (x0 - h, y0 - h, x1 + h, y1 + h), body: at(x0, y0, rect(
          width: (x1 - x0) * 1pt, height: (y1 - y0) * 1pt, radius: BOX.r * 1pt,
          stroke: (paint: INK, thickness: BOX.lw * 1pt, dash: BOX.dash, cap: "butt")))),
        label(if right { x1 - 8 } else { x0 + 8 }, y0 + 10, b.label, BOX.label,
          anchor: if right { "right" } else { "left" }) + (of: b.id)))
      boxes.insert(b.id, (x0 - h, y0 - h, x1 + h, y1 + h))
    }
  }
  items += range(residuals.len()).map(i => skips.at(str(i))).flatten()

  // spines: centre to centre under the glyphs. Across lanes a spine elbows with square corners:
  // out of a split just below the node the lanes share, into a merge midway above the node they
  // meet at (the two branches of a concatenate each into its own ring).
  for n in nodes.filter(n => drawn(n) and not skip(n)) {
    // a residual's skip arrives by its loop, not by the spine
    let looped = residuals.filter(r => r.to == n.id).map(r => (r.from, get(r, "projection"))).flatten()
    let srcs = inputs(n).filter(i => by.at(i).type != "input" and not skip(by.at(i)) and i not in looped)
    let (x, yn) = (pos.at(n.id).x, pos.at(n.id).y)
    if n.type == "concatenate" and srcs.len() == 2 {
      let low = calc.max(..srcs.map(i => pos.at(i).y + glyphs.at(i).hh))
      let jog = (low + yn - HALO) / 2
      let xs = srcs.sorted(key: i => pos.at(i).x)
      for (i, cx) in xs.zip((x - CIRCLE.d * CIRCLE.concat, x + CIRCLE.d * CIRCLE.concat)) {
        items.push(line-item(Z.spine, ((pos.at(i).x, pos.at(i).y), (pos.at(i).x, jog), (cx, jog), (cx, yn - HALO)), SPINE))
      }
    } else {
      for i in srcs.filter(i => pos.at(i).x == x) { items.push(line-item(Z.spine, ((pos.at(i).x, pos.at(i).y), (x, yn)), SPINE)) }
      let across = srcs.filter(i => pos.at(i).x != x)
      if across.len() > 0 {
        let top = if n.type in ("add", "concatenate") { HALO } else { glyphs.at(n.id).hh }
        let jog = acc.splits.at(n.id, default: (calc.max(..across.map(i => pos.at(i).y + glyphs.at(i).hh)) + yn - top) / 2)
        for i in across {
          let dx = pos.at(i).x - x
          let tx = if n.type == "concatenate" and n.id not in acc.splits {
            x + CIRCLE.d * CIRCLE.concat * (if dx < 0 { -1 } else { 1 }) } else { x }
          items.push(line-item(Z.spine, ((pos.at(i).x, pos.at(i).y), (pos.at(i).x, jog), (tx, jog), (tx, yn)), SPINE))
        }
      }
    }
  }
  items += nodes.filter(drawn).map(n => own.at(n.id)).flatten()
  items += p.boxes.sorted(key: b => -b.depth).map(b => framed.at(b.id)).flatten()
  // a spine end clears the boxes round the glyph it joins
  let clear-top(id, y) = calc.min(y, ..p.anc.at(id, default: ()).map(b => boxes.at(b).at(1)))
  let clear-bottom(id, y) = calc.max(y, ..p.anc.at(id, default: ()).map(b => boxes.at(b).at(3)))

  // spine ends: input chevrons above the first glyph, output terminals below the last
  for n in nodes.filter(n => n.type == "input") {
    let first = nodes.find(m => drawn(m) and (inputs(m).contains(n.id) or (branch(m) == branch(n) and not skip(m))))
    let x = pos.at(n.id).x
    let top0 = pos.at(first.id).y - glyphs.at(first.id).hh
    let y0 = clear-top(first.id, top0) - STUB - CHEVRON
    items.push((z: Z.glyph, bb: (x - CHEVRON / 2, y0, x + CHEVRON / 2, y0 + CHEVRON), body: at(x, 0.0, chevron(y0))))
    items.push(line-item(Z.spine, ((x, y0 + CHEVRON / 2), (x, top0 + BLOCK.lw)), SPINE))
    if get(n, "label") != none { items.push(label(x, y0 - 9, n.label, 10)) }
  }
  for n in nodes.filter(n => n.type == "output") {
    let last = inputs(n).first()
    let x = pos.at(last).x
    let y0 = pos.at(last).y + glyphs.at(last).hh - BLOCK.lw / 2
    let kind = get(n, "kind", default: "binary")
    let y-out = clear-bottom(last, y0)
    if y-out > y0 { items.push(line-item(Z.spine, ((x, y0), (x, y-out)), SPINE)); y0 = y-out }
    let classes = get(n, "classes", default: 2)
    let fills = if kind == "binary" { (PAPER, INK) } else if kind == "scalar" { (INK,) } else if kind == "classes" and classes <= 4 {
      range(classes).map(_ => PAPER) } else { (PAPER,) }
    let yb = y0 + STUB + TERMINAL.d + TERMINAL.lw / 2
    if kind == "arrow" {
      items.push(line-item(Z.spine, ((x, y0), (x, y0 + STUB / 2 + CHEVRON / 2)), SPINE))
      items.push((z: Z.glyph, bb: (x - CHEVRON / 2, y0, x + CHEVRON / 2, y0 + STUB / 2 + CHEVRON),
        body: at(x, 0.0, chevron(y0 + STUB / 2))))
      yb = y0 + STUB / 2 + CHEVRON
    } else {
      for (i, fill) in fills.enumerate() {
        let xi = x + TERMINAL.dx * (2 * i - (fills.len() - 1))
        items.push(line-item(Z.spine, ((xi, y0), (xi, y0 + STUB)), SPINE))
        items.push(put(Z.glyph, xi, y0 + STUB + TERMINAL.d / 2,
          glyph(TERMINAL.d / 2 + TERMINAL.lw / 2, TERMINAL.d / 2 + TERMINAL.lw / 2, disc(0.0, 0.0, TERMINAL.d / 2, fill: fill, lw: TERMINAL.lw))))
      }
      if kind == "classes" and classes > 4 { items.push(label(x + 12, y0 + STUB + TERMINAL.d / 2, "×" + str(classes), 10, anchor: "left")) }
    }
    if get(n, "label") != none { items.push(label(x, yb + 10, n.label, 10)) }
  }

  // the hyperparameter table, each row centred on its glyph; rows of the outer lanes mirror
  let widths = cols.map(c => get(c, "width", default: if c.key == "type" { TABLE.type-w } else { TABLE.value-w }))
  let total = widths.sum()
  let cell(n, c) = {
    let cells = get(n, "cells", default: (:))
    if c.key in cells { return str(cells.at(c.key)) }
    if c.key == "type" { return get(n, "name", default: if n.type == "block" { n.label } else { n.type }) }
    if get(n, "blank_row", default: false) { return "" }
    let blank = get(table, "blank", default: "-")
    if c.key == "activation" { return ACT_NAME.at(get(n, "activation", default: "") , default: get(n, "activation", default: blank)) }
    if c.key == "dropout" { return if get(n, "dropout") != none { str(n.dropout) } else { blank } }
    if v2 and c.key == "norm" { return if get(n, "norm") != none { NORM_NAME.at(n.norm) } else { blank } }
    let params = get(n, "params", default: (:))
    let k = get(c, "from", default: (c.key,)).find(k => k in params)
    if k == none { blank } else { str(params.at(k)) }
  }
  let draw-table(rows, x0) = {
    let out = ()
    let xs = widths.enumerate().map(((i, w)) => x0 + widths.slice(0, i).sum(default: 0) + w / 2)
    // the header band fits its tallest header, as the figures do (two lines: about 30 pt)
    let head(yc) = cols.zip(xs, widths).map(((c, cx, w)) => label(cx, yc, c.header, get(c, "header_size", default: TABLE.header), width: w - 2))
    let band = calc.max(TABLE.header-min, ..head(0.0).map(h => h.bb.at(3) - h.bb.at(1) + TABLE.header-pad))
    out += head(-band / 2)
    for yy in (0.0, bottom) { out.push(line-item(Z.text, ((x0, yy), (x0 + total, yy)), TABLE.rule)) }
    for n in rows {
      for (c, cx, w) in cols.zip(xs, widths) {
        let v = cell(n, c)
        if v != "" {
          out.push(label(cx, pos.at(n.id).y, v, if c.key == "type" { TABLE.type } else { TABLE.value }, weight: MEDIUM, width: w - 4))
        }
      }
    }
    for rep in p.repeats {
      let ya = pos.at(rep.first).at("top", default: pos.at(rep.first).y - pitch(by.at(rep.first)) / 2)
      // a row-less last glyph (the add closing a residual box) carries the rule through its centre
      let yb = pos.at(rep.last).y + if get(by.at(rep.last), "table", default: true) { pitch(by.at(rep.last)) / 2 } else { 0 }
      for yy in (ya, yb) {
        out.push((z: Z.text, bb: (x0, yy, x0 + total, yy), body: place(top + left, curve(
          stroke: (paint: INK, thickness: TABLE.rule * 1pt, dash: (6pt, 2pt, 1pt, 2pt)),
          curve.move(pt2((x0, yy))), curve.line(pt2((x0 + total, yy)))))))
      }
      let (bx, ym) = (x0 - 6, (ya + yb) / 2)
      out.push((z: Z.text, bb: (bx - 10, ya, bx, yb), body: place(top + left, curve(stroke: ink(TABLE.rule),
        curve.move(pt2((bx, ya))), curve.quad(pt2((bx - 5, ya)), pt2((bx - 5, ya + 5))), curve.line(pt2((bx - 5, ym - 5))),
        curve.quad(pt2((bx - 5, ym)), pt2((bx - 10, ym))), curve.quad(pt2((bx - 5, ym)), pt2((bx - 5, ym + 5))),
        curve.line(pt2((bx - 5, yb - 5))), curve.quad(pt2((bx - 5, yb)), pt2((bx, yb)))))))
      out.push(label(bx - 14, ym - 9, "×" + str(rep.times), 20, anchor: "right"))
      out.push(label(bx - 14, ym + 11, get(rep, "label", default: ""), 11, anchor: "right"))
    }
    out
  }
  let rows = nodes.filter(n => drawn(n) and get(n, "table", default: true))
  let gx0 = calc.min(..items.map(i => i.bb.at(0)))
  let gx1 = calc.max(..items.filter(i => i.z != Z.text).map(i => i.bb.at(2)))
  if placement == "outer" and nodes.any(n => branch(n) != "main") {
    let on(s) = rows.filter(n => branch(n) == "main" or pos.at(n.id).side == s)
    items += draw-table(on(-1), gx0 - TABLE.gap - total)
    items += draw-table(on(1), gx1 + TABLE.gap)
  } else {
    items += draw-table(rows, gx0 - TABLE.gap - total)
  }

  // the canvas: every item in z order, shifted so the drawing starts at the top-left
  let pad = 8.0
  let (x0, y0) = (calc.min(..items.map(i => i.bb.at(0))) - pad, calc.min(..items.map(i => i.bb.at(1))) - pad)
  let (x1, y1) = (calc.max(..items.map(i => i.bb.at(2))) + pad, calc.max(..items.map(i => i.bb.at(3))) + pad)
  // each block's place on the canvas (pt, the SVG's own units), for `typst query <nnblock>`
  let meta = p.blocks.map(b => {
    let bb = if b.expanded { boxes.at(b.id) } else {
      let (q, g) = (pos.at(b.id), glyphs.at(b.id))
      (q.x + g.x0, q.y - g.hh, q.x + g.x1, q.y + g.hh)
    }
    let row = if b.expanded { (bb.at(1), bb.at(3)) } else { (pos.at(b.id).top, pos.at(b.id).top + pitch(by.at(b.id))) }
    [#metadata(b + (bb: (bb.at(0) - x0, bb.at(1) - y0, bb.at(2) - x0, bb.at(3) - y0),
      row: (row.at(0) - y0, row.at(1) - y0), canvas: (x1 - x0, y1 - y0))) <nnblock>]
  })
  box(width: (x1 - x0) * 1pt, height: (y1 - y0) * 1pt, fill: PAPER,
    place(top + left, dx: -x0 * 1pt, dy: -y0 * 1pt, box(width: 0pt, height: 0pt,
      items.sorted(key: i => i.z).map(i => i.body).join() + meta.join())))
}

// --- entry point: one page per spec (`--input spec=a.json` or `--input spec=a.json,b.json`) ---
// `--input expand=all` or `--input expand=id1,id2` opens blocks (and their ancestors);
// `--input vocab=1` publishes the vocabulary for `validate.py --check-vocab`.
#if "spec" in sys.inputs {
  set page(width: auto, height: auto, margin: 0pt, fill: PAPER)
  let e = sys.inputs.at("expand", default: "")
  let expand = if e == "all" { "all" } else if e == "" { () } else { e.split(",") }
  sys.inputs.spec.split(",").map(p => diagram(json(p), expand: expand)).join(pagebreak())
}
#if "vocab" in sys.inputs {
  [#metadata((types: SYMBOLS.keys(), kinds: BLOCK_KINDS.keys(), columns: STD_COLUMNS.keys(),
    activations: ACT_NAME.keys(), norms: NORM_MARK.keys())) <nnvocab>]
}
