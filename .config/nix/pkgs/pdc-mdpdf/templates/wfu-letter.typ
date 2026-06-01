// Pandoc-Typst template for WFU letters of recommendation
// Available variables: date, greeting, closing, signer,
//   signature-block, logo, logo-width, body

#set page(
  paper: "us-letter",
  margin: (top: 1.3in, bottom: 1.3in, left: 1in, right: 1in),
  numbering: none,
  header: [
    #set line(stroke: rgb("#$if(accent-color)$$accent-color$$else$000000$endif$") + 1pt)
    #line(length: 100%)
  ],
  footer: [
    #set line(stroke: rgb("#$if(accent-color)$$accent-color$$else$000000$endif$") + 1pt)
    #line(length: 100%)
  ],
)

#set text(
  font: "Palatino",
  size: 11pt,
)

#set par(
  justify: false,
  first-line-indent: 1.5em,
  leading: 0.7em,
)

// Paragraph spacing (Pandoc compatibility)
#set par(spacing: 0.65em)

$if(highlighting-macros)$
$highlighting-macros$
$endif$

$for(header-includes)$
$header-includes$
$endfor$

// Logo — first page only
$if(logo)$
#context {
  if counter(page).get().first() == 1 {
    image("$logo$", width: $if(logo-width)$$logo-width$$else$35%$endif$)
  }
}
$endif$

// Date, right-aligned
#v(-0.5cm)
#align(right)[
  #text(size: 10pt)[
    $if(date)$$date$$else$#datetime.today().display("[month repr:long] [day], [year]")$endif$
  ]
]

#v(0.5cm)

// Greeting — suspend first-line indent
#par(first-line-indent: 0em)[$greeting$]

$body$

#v(0.5cm)

// Closing
#par(first-line-indent: 0em)[$closing$]

#v(0.75cm)

// Signer
#par(first-line-indent: 0em)[$signer$]

#v(0.25cm)

// Signature block
$if(signature-block)$
#par(first-line-indent: 0em)[
  #text(size: 10pt)[
    $for(signature-block)$$signature-block$#linebreak()$endfor$
  ]
]
$endif$
