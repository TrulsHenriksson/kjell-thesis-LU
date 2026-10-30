#import "@preview/codly:1.3.0": *
#import "@preview/great-theorems:0.1.2": *
#import "@preview/rich-counters:0.2.2": *

#import "localization.typ": ordinal, date-display, locale, lu-logo-path


// Counter that always starts with the subsection number
#let mathcounter = rich-counter(
  identifier: "mathcounter",
  inherited_levels: 2
)

// Theorem environments

#let common-mathblock = mathblock.with(
  counter: mathcounter,
  // We use the heading numbering since it changes in the appendices
  numbering: (..nums) => numbering(heading.numbering, ..nums),
  above: 1.2em,
  below: 1.2em,
  // Format references without extra surrounding parentheses
  titlix: x => if type(x) == content and x.has("target") [#x] else [(#x)],
)
#let italics-mathblock = common-mathblock.with(
  bodyfmt: emph,
)

#let theorem = italics-mathblock(
  blocktitle: context locale.at(text.lang).Theorem,
)
#let proposition = italics-mathblock(
  blocktitle: context locale.at(text.lang).Proposition,
)
#let conjecture = italics-mathblock(
  blocktitle: context locale.at(text.lang).Conjecture,
)
#let lemma = italics-mathblock(
  blocktitle: context locale.at(text.lang).Lemma,
)
#let corollary = italics-mathblock(
  blocktitle: context locale.at(text.lang).Corollary,
)

#let definition = common-mathblock(
  blocktitle: context locale.at(text.lang).Definition,
)
#let example = common-mathblock(
  blocktitle: context locale.at(text.lang).Example,
  prefix: count => [_#{ context locale.at(text.lang).Example } #count._],
)
#let note = common-mathblock(
  blocktitle: context locale.at(text.lang).Note,
  prefix: count => [_#{ context locale.at(text.lang).Note } #count._],
)
#let remark = common-mathblock(
  blocktitle: context locale.at(text.lang).Remark,
  prefix: count => [_#{ context locale.at(text.lang).Remark } #count._],
)

#let proof = proofblock(
  blocktitle: context locale.at(text.lang).Proof,
  suffix: [#h(1fr) $square.filled.medium$],
)



// Typst equivalents of LaTeX font sizes (https://www.sascha-frank.com/latex-font-size.html)
#let size-tiny = 6pt
#let size-scriptsize = 8pt
#let size-footnotesize = 9pt
#let size-small = 10pt
#let size-normalsize = 11pt
#let size-large = 12pt
#let size-Large = 14pt
#let size-LARGE = 17pt
#let size-huge = 20pt
#let size-Huge = 25pt

#let margin-inside = 3.1cm
#let margin-outside = 5.1cm

#let first-line-indent = 1.8em
#let indent = h(first-line-indent)


// Add equation numbers to only the referenced equations
#let only-number-referenced-equations(body) = context {
  let equation-labels = query(math.equation.where(block: true))
    .filter(eq => eq.has("label"))
    .map(eq => eq.label)
    .dedup()
  
  if equation-labels.len() == 0 {
    return body
  }
  
  let referenced-equations = query(
    selector.or(..equation-labels.map(
      label => ref.where(target: label)
    ))
  ).map(it => it.target)
  if referenced-equations.len() == 0 {
    return body
  }

  // Display equation numbers using the same counter as theorems.
  // We use the heading numbering since it changes in appendices.
  show selector.or(..referenced-equations): it => {
    (mathcounter.step)()
    it
  }
  show selector.or(..referenced-equations): set math.equation(
    numbering: nums => context (mathcounter.display)("(" + heading.numbering + ")"),
  )
  // Fix the reference numbers
  show selector.or(..equation-labels.map(
    label => ref.where(target: label)
  )): it => {
    let (..nums, last) = (mathcounter.at)(it.target)
    // The last digit is always one less than it should be (for some reason)
    link(
      it.element.location(),
    )[#it.element.supplement #numbering(heading.numbering, ..nums, last + 1)]
  }

  body
}

// Adapted from https://stackoverflow.com/a/78289423
#let section-numbering(c) = {
  if c.numbering == none {
    return ""
  }
  return numbering(c.numbering + ". ", ..counter(heading).at(c.location()))
}

// Return the chapter on the current page, and how many pages ago it started
#let first-section-before-here(level: 1) = {
  // The headings whose names should be shown in the headers
  let wanted-headings = selector(heading.where(level: level))

  let elems = query(wanted-headings.after(here()))
  // Is there a heading on the same page?
  if elems.len() != 0 and elems.first().location().page() == here().page() {
    // Return the last available heading that is on this page
    return (elems.filter(e => e.location().page() == here().page()).last(), 0)
  }

  elems = query(wanted-headings.before(here()))
  if elems.len() == 0 {
    return (none, 0)
  }

  let result = elems.last()
  return (result, here().page() - result.location().page())
}



// Create a title page from the document data.
#let title-page(
  level: "Bachelor's",
  subject: "Mathematics",
  advisor: "(Advisor not set)",
) = context {
  if document.title == none {
    panic("Cannot create title page: No title given. Set it using #set document(title: [...]).")
  }
  if document.author.len() == 0 {
    panic("Cannot create title page: No author given. Set it using #set document(author: ...).")
  }
  if document.date in (none, auto) {
    panic("Cannot create title page: No date given. Set it using #set document(date: ...)")
  }
  set text(size: size-large)
  set par(justify: false)
  set page(numbering: none, header: none)
  show title: set text(size: size-huge)

  pagebreak(weak: true)
  grid(
    columns: (100%,),
    align: (center,),
    rows: (auto, 1fr, auto, auto, auto, 1fr, auto),

    title(),

    [],  // Fill the available height

    [#document.author.join([,#v(0.15em)])],
    v(1.2em),
    [#date-display.at(text.lang)(document.date)],

    [],  // Fill the available height

    image(lu-logo-path.at(text.lang), height: 24%),
    v(2em),
    (locale.at(text.lang).Thesis-in)(level, subject),
    v(1.2em),
    [#locale.at(text.lang).Thesis-advisor: #advisor],
  )
  // Blank backside
  page[]

  // The page counter should only begin counting after the title page
  counter(page).update(1)
}

// Create the abstract page (always English). The title is added automatically.
#let abstract(body) = {
  set page(header: none)
  show heading: set block(below: 2em)
  show heading: set text(size: size-large)

  // Make sure the abstract starts on a new page
  pagebreak(to: "odd", weak: true)
  v(2em)
  align(center, heading(numbering: none, outlined: false)[Abstract])

  body

  // Backside, blank page
  pagebreak(to: "odd", weak: true)
}

// Make headings unnumbered within the body.
#let no-number(body) = {
  show heading: set heading(numbering: none)
  body
}

// The frontmatter is numbered using lowercase Roman numerals.
#let frontmatter(body) = {
  set page(numbering: "i")

  body

  // After the frontmatter, the pages start counting from 1 again
  pagebreak(to: "odd", weak: true)
  counter(page).update(1)
}

// Add appendices. Write the contents within the body.
#let appendices(body) = {
  set heading(numbering: "A.1")
  show heading.where(level: 1): set heading(supplement: context locale.at(text.lang).Appendix)
  counter(heading).update(0)

  body
}

// Convenience function for entering code.
#let input-code(file-path, header: none, lang: "python") = {
  if header != none {
    codly(header: [#header])
  }
  raw(read(file-path), lang: lang, block: true)
}


#let thesis-style(body, cover-page: none, cm-mathfont: false) = {
  if cover-page != none and type(cover-page) != path {
    panic("Could not apply cover page: The path to the cover page must be supplied as a `path`.")
  }

  // Initialize packages
  show: great-theorems-init
  show: codly-init

  // Set page style, headers and footers
  set page(
    numbering: "1",
    margin: (
      inside: margin-inside,
      outside: margin-outside,
      top: 5cm,
      bottom: 4.7cm,
    ),
    header: context {
      // No header on pages where a chapter starts
      if first-section-before-here(level: 1).at(1) == 0 {
        return
      }

      let recto = calc.odd(here().page())
      let heading-level = if recto { 2 } else { 1 }
      let (section-here, pages-ago) = first-section-before-here(level: heading-level)

      if section-here == none and heading-level == 2 {
        // There was no sub-section, take the last chapter instead
        heading-level = 1
        (section-here, pages-ago) = first-section-before-here(level: 1)
      }
      // No header if a section wasn't found
      if section-here == none {
        return
      }

      // The header is placed in the middle of each page according to the inside margin, ignoring the binding bias
      pad(
        left: if recto { 0cm } else { margin-inside - margin-outside },
        right: if recto { margin-inside - margin-outside } else { 0cm },
        {
          align(if recto { right } else { left })[
            #section-numbering(section-here)#if heading-level == 1 {
              smallcaps(section-here.body)
            } else {
              section-here.body
            }
          ]
          line(length: 100%, stroke: 0.4pt)
        }
      )
    },
    footer: context {
      // Skip pages that aren't numbered
      if here().page-numbering() == none {
        return
      }

      let recto = calc.odd(here().page())
      let alignment = if recto { right } else { left }
      let (chapter-here, pages-ago) = first-section-before-here(level: 1)
      // The footer is placed in the middle of each page according to the inside margin, ignoring the binding bias
      let (left-padding, right-padding) = if recto {
        (0cm, margin-inside - margin-outside)
      } else {
        (margin-inside - margin-outside, 0cm)
      }

      // Align to center if on a chapter start
      if chapter-here != none and pages-ago == 0 {
        alignment = center
        (left-padding, right-padding) = (0cm, 0cm)
      }

      pad(
        left: left-padding,
        right: right-padding,
        align(
          alignment,
          counter(page).display(),
        )
      )
    },
  )

  // Set text style
  set par(
    leading: 0.60em,
    spacing: 0.60em,
    first-line-indent: first-line-indent,
    justify: true
  )
  set text(
    size: size-normalsize,
    font: ("EB Garamond",),
    number-type: "old-style"
  )

  // Set equation style
  show math.equation: set text(
    font: if cm-mathfont { "New Computer Modern Math" } else { "Garamond-Math" },
    weight: "regular",
    stylistic-set: if cm-mathfont {
      // See https://ctan.org/texarchive/fonts/newcomputermodern for explanations of the stylistic sets
      (
        // 1, // Turn $cal()$ into $scr()$ ("more scripty")
        // 2, // Upright $integral$ signs
        3, // More shaded blackboard bold letters
        // 4, // Devanagari digits
        // 5, // Smallcaps blackboard bold letters
        // 6, // Alternative lighter $cal()$
      )
    } else {
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
    },
  )
  show math.equation.where(block: true): set block(above: 1.2em, below: 1.2em)
  show: only-number-referenced-equations


  // Style code blocks
  codly(
    header-cell-args: (align: center,), 
    header-repeat: true, 
    header-transform: emph,
    lang-format: none,
    number-align: right + horizon,
    number-format: n => pdf.artifact(str(n), kind: "line-number"),
  )

  // Set heading styles
  set heading(numbering: "1.1")
  show heading.where(level: 1): set heading(supplement: context locale.at(text.lang).Chapter)
  show heading.where(level: 2): set text(size: size-Large)
  show heading.where(level: 2): set block(below: 1.2em, above: 1.75em)
  show heading.where(level: 3): set text(size: size-large)
  show heading.where(level: 3): set block(below: 1.2em, above: 1.75em)

  // Level-1 headings are chapter headings and start on a new page
  show heading.where(level: 1): it => {
    set par(justify: false, first-line-indent: 0pt)
    let heading-content = it.body

    if heading-content == [Abstract] {
      // Don't style the abstract heading
      return it
    }

    pagebreak(to: "odd", weak: true)
    v(5em)
    // Block here so the first paragraph isn't indented
    block(below: 3.5em)[
      #if it.numbering != none and it.outlined {
        // "Chapter/Appendix n" on a line before the chapter title
        strong(
          text(size: size-huge)[
            #smallcaps[
              #it.supplement
              #counter(heading).display(
                it.numbering.replace(regex("\.\s*$"), ""), // Remove the dot at the end
              )
            ]
            \
            \
          ],
        )
      } else if it.numbering != none {
        // "n." before the heading as usual
        heading-content = [
          #counter(heading).display(it.numbering) #heading-content
        ]
      }
      #strong(text(size: size-Huge, heading-content))
    ]
  }

  // Style the chapters differently in the outline
  show outline.entry.where(level: 1): set block(above: 1.2em)
  show outline.entry.where(level: 1): set outline.entry(fill: none)
  show outline.entry.where(level: 1): strong

  // Set citation style
  set cite(style: "alphanumeric")

  // TODO: style tables


  // Front cover page
  if cover-page != none {
    set page(header: none, footer: none)
    page(background: image(cover-page, page: 1))[]
    page[]
    counter(page).update(1)
  }

  // Internals
  body

  // Back cover page
  if cover-page != none {
    set page(header: none, footer: none)
    pagebreak(to: "odd", weak: true)
    page[]
    page(background: image(cover-page, page: 2))[]
  }
}