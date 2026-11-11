options(
  repo = c(CRAN = "https://cran.rstudio.com/"),
  browser = if (Sys.info()[["sysname"]] == "Darwin") {
    "open -a 'Helium'"
  } else {
    b <- Sys.getenv("BROWSER")
    if (nzchar(b)) b else "xdg-open"
  }
)
