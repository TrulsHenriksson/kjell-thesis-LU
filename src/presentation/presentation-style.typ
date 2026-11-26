#import "@preview/codly:1.3.0": *
#import "@preview/polylux:0.4.0": *

#import "../constants.typ" as constants
#import "../colors.typ": *
#import "../logic.typ": *
#import "../localization.typ": ordinal, date-display, locale, lu-logo-path



#let place-seal() = {
  let logo-height = 12cm
  place(
    right + bottom,
    dx: 3.7cm * (logo-height / 15cm),
    dy: 8.1cm * (logo-height / 15cm),
    image("../assets/LundUniversity_C2line_RGB.png", height: logo-height),
  )
}


#let title-slide(background-color: "blue", type-of-work: [Type of work], course: [Course code], cycle: [Cycle], department: [Department], title-short: []) = slide[
  #set page(
    margin: 5mm,
    header: none,
    footer: none,
  )
  #set par(justify: false)
  #set text(fill: lu-bronze.tint(100%))
  #show title: set text(font: "Adobe Garamond Pro", weight: "semibold")
  #show title: set par(leading: 0.45em)

  // TODO: Use the correct colors for the background image, or a transparent image
  #box(height: 100%, fill: bg-colors.at(background-color).tint(100%))[
    #set align(bottom)
    // TODO: Replace with transparent image
    #image("../assets/title-image-" + background-color + ".png")
    #place(
      right + top,
      dx: 0.1pt, // To definitely cover the image edge
      box(height: 13cm)[
        #set align(horizon)
        #box(
          width: 19cm,
          fill: white,
          inset: (right: 0mm, rest: 6mm),
        )[
          #set align(left)

          #title()
          #line(length: 100%)
          #grid(
            columns: (1fr, 1fr),
            row-gutter: 0.6em,

            context document.author.map(strong).join([, ]), text(0.75em, type-of-work),
            text(0.75em, department), text(0.75em)[#course, #cycle],
          )
        ]
      ] 
    )
    #metadata(title-short) <title-short>
  ]

  #place-seal()
  #counter(page).update(0)
]


#let section-slide(section-title, background-color: "brown") = slide[
  #toolbox.register-section(section-title)
  #set page(
    margin: 5mm,
    header: none,
    footer: none,
  )
  #set align(bottom)

  #box(
    width: 100%,
    height: 100%,
    inset: 15%,
    fill: bg-colors.at(background-color).tint(100%),

    grid(rows: (1fr, 1fr))[
      #heading(section-title, level: 1)
      #if section-title != [] { line(length: 100%) }
    ][]
  )

  #place-seal()
]


#let presentation-footer = context {
  set text(fill: lu-bronze.tint(100%), size: 16pt)
  line(length: 100%)
  grid(
    columns: (2fr, 3fr, 2fr), align: (left, center, right),
    emph(query(<title-short>).first(default: (value: [])).value),
    {
      set par(leading: 0.4em)
      toolbox.current-section
    },
    [#toolbox.slide-number / #toolbox.last-slide-number]
  )
}


#let presentation-style(body, garamond-mathfont: false) = {
  // Initialize packages
  show: codly-init

  // Set page style, headers and footers
  set page(
    width: 297mm,
    height: 297mm * 10/16,
    numbering: "1",
    margin: (
      x: 6%,
      top: 10%,
      bottom: 10%,
    ),
    footer-descent: 20%,
    // header: box(width: 100%, height: 100%, fill: blue),
    footer: presentation-footer,
  )

  // Set text style
  set par(
    leading: constants.par-leading,
    spacing: 1.0em,
    first-line-indent: constants.first-line-indent,
    justify: true
  )
  set text(
    size: 20pt,
    font: ("Frutiger LT Std", "Arial"),
    weight: "light",
  )

  // Set heading styles
  set heading(offset: 1)  // Level 1 headings are only accessible via #section-slide
  show heading.where(level: 1): set text(
    size: 36pt,
    font: ("Adobe Garamond Pro", "Times New Roman"),
    weight: "semibold",
    fill: lu-bronze.tint(100%),
  )
  show heading.where(level: 2): set block(above: 1.2em, below: 0.8em)
  show heading.where(level: 2): set text(
    size: 32pt,
    font: ("Adobe Garamond Pro", "Times New Roman"),
    weight: "semibold",
    fill: lu-bronze.tint(100%),
  )
  show heading.where(level: 3): set block(above: 1.2em, below: 0.6em)
  show heading.where(level: 3): set text(
    size: 20pt,
    font: ("Frutiger LT Std", "Arial"),
    weight: "bold",
    fill: lu-bronze.tint(100%),
  )
  show heading.where(level: 4): set block(above: 1.2em, below: 0.6em)
  show heading.where(level: 4): set text(
    size: 14pt,
    font: ("Frutiger LT Std", "Arial"),
    weight: "bold",
    fill: lu-grey.tint(100%),
  )
  show heading.where(level: 4): upper

  // Set equation style
  show: only-number-referenced-equations
  show math.equation: set text(
    font: if garamond-mathfont { "Garamond-Math" } else { "New Computer Modern Math" },
    weight: "regular",
    stylistic-set: if garamond-mathfont {
      // See https://mirrors.mit.edu/CTAN/fonts/garamond-math/Garamond-Math.pdf for examples of the stylistic sets
      (
        // 1, // Rounded XITS Math blackboard bold letters (sans-serif)
        2, // Curved $partial$
        // 3, // Computer Modern $cal()$ and $scr()$ letters
        // 4, // Lighter $bold()$
        // 5, // Heavier $bold()$
        6, // Horizontal bar over $\u{0127}$
        7, // Nicer $integral$ symbols
        8, // Native Garamond $cal()$ and $scr()$ letters
        9, // More legible $tilde()$ symbols
        10, // Out-bent italic $h$
        // 11, // Larger binary operators
      )
    } else {
      // See https://ctan.org/texarchive/fonts/newcomputermodern for explanations of the stylistic sets
      (
        // 1, // Turn $cal()$ into $scr()$ ("more scripty")
        // 2, // Upright $integral$ signs
        3, // More shaded blackboard bold letters
        // 4, // Devanagari digits
        // 5, // Smallcaps blackboard bold letters
        // 6, // Alternative lighter $cal()$
      )
    },
  )
  show math.equation.where(block: true): set block(
    above: constants.block-above,
    below: constants.block-below,
  )
  set math.mat(delim: "[")


  // Style footnotes
  show footnote: set text(fill: lu-grey.tint(100%))
  show footnote.entry: set text(size: 16pt, fill: lu-grey.tint(100%))
  show footnote.entry: set align(right)
  set footnote.entry(
    separator: none,
    clearance: constants.block-above,
  )

  // Style lines
  set line(stroke: 0.8pt + lu-bronze.tint(100%))

  // Style code blocks
  codly(
    header-cell-args: (align: center,),
    header-repeat: true,
    header-transform: emph,
    lang-format: none,
    number-align: right + horizon,
    number-format: n => pdf.artifact(str(n), kind: "line-number"),
  )

  // Style the outline
  show outline: it => slide[
    // TODO: Use columns(separator: ...) in Typst 0.16
    #show heading: place.with(top, float: true, scope: "parent")
    #show: columns.with(2)
    #it
  ]
  set outline(depth: 2)
  show outline: set heading(bookmarked: true)
  show outline.entry: it => link(
    it.element.location(),
    it.indented(if it.level == 1 {sym.bullet}, it.body()),
  )
  show outline.entry: set text(0.9em)
  show outline.entry.where(level: 1): set text(20pt, fill: lu-bronze.tint(100%))
  show outline.entry.where(level: 1): set block(above: constants.block-above)
  show outline.entry.where(level: 1): strong

  // Set citation style
  set cite(style: "alphanumeric")

  // Style tables
  set table(
    stroke: (x, y) => (
      top: if y <= 1 { constants.line-stroke } else { 0pt },
      bottom: constants.line-stroke, // Overridden by top everywhere except the last row
    ),
  )
  show figure.where(kind: table): set block(breakable: true)
  show table.cell.where(y: 0): strong
  set table.hline(stroke: constants.line-stroke)
  set table.vline(stroke: constants.line-stroke)

  // Style figures
  set figure(gap: 0.75em)
  show figure: set block(above: constants.block-above, below: constants.block-below)

  // Style quotes
  show quote.where(block: true): set pad(x: constants.quote-pad)
  show quote.where(block: true): set block(
    above: constants.block-above + 0.5 * constants.par-leading,
    below: constants.block-below + 0.5 * constants.par-leading,
  )

  // Style lists
  set list(
    marker: ([#sym.bullet], [#sym.bullet.tri], [--],).map(it => text(fill: lu-bronze.tint(100%), it)),
  )
  set enum(numbering: "1ai.")
  set terms(hanging-indent: 1.5em)

  body
}