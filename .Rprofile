.First <- function() {
  r <- getOption("repos")
  r["CRAN"] <- "https://cloud.r-project.org"
  options(repos = r)
}

# Load `colorout`, check if it is installed
if (!requireNamespace("colorout", quietly = TRUE)) {
  pak::pak("jalvesaq/colorout")
}

# suppressMessages(require(colorout))
#
# setOutputColors256(
#   number = "\x1b[38;2;192;202;245m",
#   negnum = "\x1b[38;2;247;118;142m",
#   # zero = "",
#   normal = "\x1b[38;2;122;162;247m",
#   # date = "",
#   string = "\x1b[38;2;192;202;245m",
#   const = 75,
#   false = "\x1b[38;2;247;118;142m",
#   true = "\x1b[38;2;158;206;106m",
#   # infinite = "",
#   # index = "",
#   # stderror = "",
#   warn = c(1, 16, 196),
#   error = c(160, 231),
#   verbose = FALSE
# )

# if (interactive()) prompt::set_prompt(prompt::new_prompt_powerline(
#   parts = list("status", "memory", "git")
# ))

# Aliases for common setups

.required_pkgs <- function() {
  # Install pak if not already installed
  if (!requireNamespace("pak", quietly = TRUE)) {
    install.packages("pak")
    pak::pak_install_extra()
  }

  # Check if the renv package is installed
  if (!requireNamespace("renv", quietly = TRUE)) pak::pak("renv")
}

# Package development
.pkg_dev <- function() {
  # Install required packages
  .required_pkgs()

  if (!requireNamespace("devtools", quietly = TRUE)) pak::pak("devtools")
  if (!requireNamespace("usethis", quietly = TRUE)) pak::pak("usethis")
  if (!requireNamespace("pkgdown", quietly = TRUE)) pak::pak("pkgdown")
  if (!requireNamespace("testthat", quietly = TRUE)) pak::pak("testthat")
  if (!requireNamespace("goodpractice", quietly = TRUE)) pak::pak("goodpractice")

  # Load the packages
  suppressMessages({
    library(devtools)
    library(usethis)
    library(pkgdown)
    library(testthat)
    library(goodpractice)
  })
  cli::cli_alert_success("Ready to develop!")
}

# Generate a list of dependencies for a project
.create_dependencies <- function(additional_pkgs = NULL) {
  # Install required packages
  .required_pkgs()

  vscode_pkgs <- c("languageserver", "httpgd", "rmarkdown", "xml2", "downlit")

  pkgs <- c(renv::dependencies(quiet = TRUE)$Package, vscode_pkgs, additional_pkgs)

  pkg_list <- pak::pkg_list()
  pkg_list <- pkg_list[pkg_list$package %in% pkgs, c("package", "version", "remoteusername")]

  # If `remoteusername` is NA, then it is a CRAN package
  pkg_list$packages <- ifelse(is.na(pkg_list$remoteusername),
    paste0(pkg_list$package, "@", pkg_list$version), paste0(pkg_list$remoteusername, "/", pkg_list$package)
  )

  writeLines(pkg_list$packages, con = "dependencies.txt")
}

.setup_renv <- function() {
  # Load the renv package (bare)
  renv::init(bare = TRUE)
}

# Restore the project dependencies
.restore_dependencies <- function() {
  # Install required packages
  .required_pkgs()

  # Read the dependencies from the file
  pkgs <- readLines("dependencies.txt")

  # Install the dependencies
  pak::pkg_install(pkgs)

  # Snapshot the dependencies
  renv::snapshot()
}

.Last <- function() {
  # savehistory(".Rhistory")
}
