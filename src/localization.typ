#let lu-logo-path = (
  "en": path("assets/LundUniversity_C2line_BLACK.png"),
  "sv": path("assets/Lunds_universitet_C2r_SVART.png"),
)

#let ordinal = (
  "en": n => (
    str(n)
      + if calc.rem(n, 100) in (11, 12, 13) {
        "th"
      } else {
        ("st", "nd", "rd").at(calc.rem(n - 1, 10), default: "th")
      }
  ),
  "sv": n => (
    str(n) 
      + if calc.rem(n, 10) in (1, 2) and calc.rem(n, 100) not in (11, 12) {
        ":a"
      } else {
        ":e"
      }
  ),
)

#let month-names = (
  "sv": ("januari", "februari", "mars", "april", "maj", "juni", "juli", "augusti", "september", "oktober", "november", "december"),
)

#let date-display = (
  "en": d => d.display(
    "[month repr:long] " + ordinal.at("en")(d.day()) + " [year]",
  ),
  "sv": d => d.display(
    ordinal.at("sv")(d.day()) + " " + month-names.at("sv").at(d.month() - 1) + " [year]",
  ),
)

#let locale = (
  "en": (
    Theorem: "Theorem",
    Proposition: "Proposition",
    Conjecture: "Conjecture",
    Lemma: "Lemma",
    Corollary: "Corollary",
    Definition: "Definition",
    Example: "Example",
    Note: "Note",
    Remark: "Remark",
    Proof: "Proof",
    Thesis-in: (level, subject) => [#level Thesis in #subject],
    Thesis-advisor: "Thesis advisor",
    Appendix: "Appendix",
    Chapter: "Chapter",
  ),
  "sv": (
    Theorem: "Sats",
    Proposition: "Påstående",
    Conjecture: "Förmodan",
    Lemma: "Lemma",
    Corollary: "Följdsats",
    Definition: "Definition",
    Example: "Exempel",
    Note: "Kommentar",
    Remark: "Anmärkning",
    Proof: "Bevis",
    Thesis-in: (level, subject) => [#{level}uppsats i #subject],
    Thesis-advisor: "Handledare",
    Appendix: "Appendix",
    Chapter: "Kapitel",
  ),
)