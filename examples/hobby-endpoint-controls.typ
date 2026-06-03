#import "../src/lib.typ" as kurvst
#import "@preview/cetz:0.5.1" as cetz

#set page(width: auto, height: auto, margin: 8mm)
#set text(size: 5pt)

#let start = (0, 0)
#let start-control = (0, 2)
#let edge-pos = (7.2, 0.5)
#let end-control = (14.2, -1)
#let end = (14.2, 1)

#let point-x(p) = p.at(0)
#let point-y(p) = p.at(1)
#let add(a, b) = (point-x(a) + point-x(b), point-y(a) + point-y(b))
#let sub(a, b) = (point-x(a) - point-x(b), point-y(a) - point-y(b))
#let scale(p, factor) = (point-x(p) * factor, point-y(p) * factor)
#let mid(a, b) = scale(add(a, b), 0.5)
#let length(p) = calc.sqrt(point-x(p) * point-x(p) + point-y(p) * point-y(p))
#let unit(p) = if length(p) == 0 { (0, 0) } else { scale(p, 1 / length(p)) }

#let source-mid = mid(start, start-control)
#let sink-mid = mid(end, end-control)

#let constrained(tangent) = {
  let edge-knot = if tangent == none { edge-pos } else { (point: edge-pos, tangent: tangent) }
  let points = (start, edge-knot, end)
  (
    curve: kurvst.hobby-spline(
      points,
      start-control: start-control,
      end-control: end-control,
      omega: 0.35,
    ),
    split: kurvst.split-through(
      points,
      start-control: start-control,
      end-control: end-control,
      omega: 0.35,
    ),
  )
}

#let control-as-through = kurvst.hobby-spline(
  (start, start-control, edge-pos, end-control, end),
  omega: 0.35,
)

#let dot(point, fill, label, anchor: "north") = {
  cetz.draw.circle(point, radius: 0.045, fill: fill, stroke: none)
  cetz.draw.content(point, text(fill: fill)[#label], anchor: anchor, padding: 0.08)
}

#let draw-tangent-guide(tangent, stroke, point: edge-pos) = {
  let direction = scale(unit(tangent), 0.78)
  cetz.draw.line(
    sub(point, direction),
    add(point, direction),
    stroke: stroke,
  )
}

#let draw-reference-line(start, end, stroke, midpoint-dots: false) = {
  cetz.draw.line(start, end, stroke: stroke)
  if midpoint-dots {
    dot(start, rgb("#b36b00"), "source midpoint", anchor: "north")
    dot(end, rgb("#b36b00"), "sink midpoint", anchor: "north")
  }
}

#let draw-points(edge-label: "edge-pos") = {
  cetz.draw.line(start, start-control, stroke: rgb("#c6c6c6") + 0.35pt)
  cetz.draw.line(end, end-control, stroke: rgb("#c6c6c6") + 0.35pt)
  dot(start, black, "start", anchor: "south")
  dot(end, black, "end", anchor: "south")
  dot(start-control, rgb("#d72638"), "start-control")
  dot(end-control, rgb("#d72638"), "end-control", anchor: "south")
  dot(edge-pos, rgb("#1b7f4c"), edge-label, anchor: "south")
}

#let variants = (
  (
    title: [no tangent],
    tangent: none,
  ),
  (
    title: [midpoint straight],
    tangent: sub(sink-mid, source-mid),
    guide-start: source-mid,
    guide-end: sink-mid,
    midpoint-dots: true,
  ),
  (
    title: [endpoint straight],
    tangent: sub(end, start),
    guide-start: start,
    guide-end: end,
  ),
  (
    title: [control point straight],
    tangent: sub(end-control, start-control),
    guide-start: start-control,
    guide-end: end-control,
  ),
  (
    title: [horizontal],
    tangent: (1, 0),
  ),
)

#let draw-constrained-row(variant) = {
  let result = constrained(variant.tangent)
  cetz.draw.content((-0.3, 1.45), variant.title, anchor: "east")
  if variant.keys().contains("guide-start") {
    draw-reference-line(
      variant.guide-start,
      variant.guide-end,
      rgb("#d99a22") + 0.35pt,
      midpoint-dots: variant.at("midpoint-dots", default: false),
    )
  }
  if variant.tangent != none {
    draw-tangent-guide(variant.tangent, rgb("#1b7f4c") + 0.45pt)
  }
  kurvst.to-cetz(result.curve, stroke: rgb("#111111") + 0.85pt)
  kurvst.to-cetz(result.split.parts.at(0), stroke: rgb("#d72638") + 1.15pt)
  kurvst.to-cetz(result.split.parts.at(1), stroke: rgb("#355c9a") + 1.15pt)
  draw-points(edge-label: if variant.tangent == none { "edge-pos" } else { "edge-pos + tangent" })
}

#cetz.canvas(length: 1.2cm, {
  for (index, variant) in variants.enumerate() {
    cetz.draw.group({
      cetz.draw.translate(y: -2.25 * index)
      draw-constrained-row(variant)
    })
  }

  cetz.draw.group({
    cetz.draw.translate(y: -2.25 * variants.len())
    cetz.draw.content((-0.3, 1.45), [controls as through points], anchor: "east")
    kurvst.to-cetz(control-as-through, stroke: rgb("#111111") + 0.85pt)
    draw-points()
  })
})

#let raw-tree-start = (-57.11691711635923, -17.776330874111665)
#let raw-tree-source-route = (-57.11691711635923, -15.444330874111664)
#let raw-tree-edge-pos = (-27.19241715873317, -12.723039171208748)
#let raw-tree-sink-route = (2.7320827988928897, -10.057747468305832)
#let raw-tree-end = (2.7320827988928897, -7.669747468305832)
#let raw-tree-start-control = raw-tree-source-route
#let raw-tree-end-control = raw-tree-sink-route

#let tree-origin = raw-tree-start
#let tree-start = sub(raw-tree-start, tree-origin)
#let tree-source-route = sub(raw-tree-source-route, tree-origin)
#let tree-edge-pos = sub(raw-tree-edge-pos, tree-origin)
#let tree-sink-route = sub(raw-tree-sink-route, tree-origin)
#let tree-end = sub(raw-tree-end, tree-origin)
#let tree-start-control = sub(raw-tree-start-control, tree-origin)
#let tree-end-control = sub(raw-tree-end-control, tree-origin)
#let tree-tangent = sub(tree-end-control, tree-start-control)

#let extracted-tree-edge(points, source-span-count) = {
  let split = kurvst.split-through(
    points,
    start-control: tree-start-control,
    end-control: tree-end-control,
    omega: 0.35,
  )
  (
    curve: split.curve,
    source: kurvst.path(..split.parts.slice(0, source-span-count)),
    sink: kurvst.path(..split.parts.slice(source-span-count)),
  )
}

#let tree-edge-anchor-knots = extracted-tree-edge(
  (
    tree-start,
    tree-source-route,
    (point: tree-edge-pos, tangent: tree-tangent),
    tree-sink-route,
    tree-end,
  ),
  2,
)

#let tree-edge-anchor-handles = extracted-tree-edge(
  (
    tree-start,
    (point: tree-edge-pos, tangent: tree-tangent),
    tree-end,
  ),
  1,
)

#let tree-dot(point, fill, label, anchor: "north") = {
  cetz.draw.circle(point, radius: 0.08, fill: fill, stroke: none)
  cetz.draw.content(point, text(fill: fill)[#label], anchor: anchor, padding: 0.14)
}

#let draw-tree-edge-points(route-points: false) = {
  cetz.draw.line(tree-start, tree-start-control, stroke: rgb("#c6c6c6") + 0.45pt)
  cetz.draw.line(tree-end, tree-end-control, stroke: rgb("#c6c6c6") + 0.45pt)
  cetz.draw.line(tree-start-control, tree-end-control, stroke: rgb("#d99a22") + 0.45pt)
  draw-tangent-guide(tree-tangent, rgb("#1b7f4c") + 0.6pt, point: tree-edge-pos)
  tree-dot(tree-start, black, "source ∏", anchor: "south")
  tree-dot(tree-end, black, "sink ∑", anchor: "south")
  tree-dot(tree-start-control, rgb("#d72638"), "source-control")
  tree-dot(tree-end-control, rgb("#d72638"), "sink-control", anchor: "south")
  tree-dot(tree-edge-pos, rgb("#1b7f4c"), "edge-pos", anchor: "south")
  if route-points {
    tree-dot(tree-source-route, rgb("#355c9a"), "source route", anchor: "west")
    tree-dot(tree-sink-route, rgb("#355c9a"), "sink route", anchor: "east")
  }
}

#cetz.canvas(length: 0.24cm, {
  cetz.draw.content((-2.0, 9.5), [extracted tree edge 15: anchor handles], anchor: "east")
  kurvst.to-cetz(tree-edge-anchor-handles.curve, stroke: rgb("#111111") + 0.9pt)
  kurvst.to-cetz(tree-edge-anchor-handles.source, stroke: rgb("#d72638") + 1.3pt)
  kurvst.to-cetz(tree-edge-anchor-handles.sink, stroke: rgb("#355c9a") + 1.3pt)
  draw-tree-edge-points(route-points: true)

  cetz.draw.group({
    cetz.draw.translate(y: -14)
    cetz.draw.content((-2.0, 9.5), [same extracted edge: anchor knots], anchor: "east")
    kurvst.to-cetz(tree-edge-anchor-knots.curve, stroke: rgb("#111111") + 0.9pt)
    kurvst.to-cetz(tree-edge-anchor-knots.source, stroke: rgb("#d72638") + 1.3pt)
    kurvst.to-cetz(tree-edge-anchor-knots.sink, stroke: rgb("#355c9a") + 1.3pt)
    draw-tree-edge-points(route-points: true)
  })
})
