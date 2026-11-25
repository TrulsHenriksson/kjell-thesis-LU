#import "@preview/rich-counters:0.2.2": *


// Counter that always starts with the subsection number
#let mathcounter = rich-counter(
  identifier: "mathcounter",
  inherited_levels: 2
)

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

