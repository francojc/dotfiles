// Generic Pandoc-Typst template
// Available variables: date, body

#set page(
  paper: "us-letter",
  margin: 1in,
  numbering: none,
)

#set text(
  font: "Arial Unicode MS",
  size: 11pt,
)

$if(highlighting-macros)$
$highlighting-macros$
$endif$

$for(header-includes)$
$header-includes$
$endfor$

$if(date)$
#align(right)[$date$]
#v(0.5cm)
$endif$

$body$
