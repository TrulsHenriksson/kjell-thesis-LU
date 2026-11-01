#import "@preview/kjell-thesis-LU:0.1.0": *
#show: thesis-style.with(
  // cover-page: path("") // Include the department's cover page here when given one.
)
// #set text(lang: "sv") // If writing in Swedish.

#set document(
  title: [Title of your thesis],
  author: ("First author", "Second author"),
  date: datetime.today(), // Change to the hand-in date once handed in.
)



#title-page(
  level: "Bachelor's",
  subject: "Mathematics",
  advisor: "Supervisor name here",
)


// Pages within the frontmatter are numbered with lowercase roman numerals.
#frontmatter[
  #abstract[
    ...
  ]

  #no-number[= Popular scientific summary
    ...
  ]

  #no-number[= Acknowledgements
    ...
  ]

  #no-number[= Introduction
    ...
  ]

  #outline()
]


= First chapter
This is where you write the main contents of your thesis.


// Appendices use alphabetic numbering.
#appendices[
  = First appendix
  ...

  // Only sources you cite show up in the bibliography.
  // A BibTeX file (.bib) can be used instead of a Hayagriva file.
  #bibliography("sources.yaml")
]
