# 00_packages.R - loads first. Checks packages and stops with a clear
# message instead of a cryptic error halfway through the app.

required_pkgs <- c("shiny", "bslib", "DT", "plotly", "ggplot2",
                   "readxl", "readr", "dplyr", "tidyr")

missing_pkgs <- required_pkgs[!vapply(required_pkgs, requireNamespace,
                                      logical(1), quietly = TRUE)]
if (length(missing_pkgs) > 0) {
  stop("Missing required packages: ", paste(missing_pkgs, collapse = ", "),
       "\nRun once:  source('install_packages.R')", call. = FALSE)
}

suppressPackageStartupMessages({
  library(shiny)
  library(bslib)
  library(DT)
  library(ggplot2)
  library(plotly)
  library(dplyr)
  library(tidyr)
  library(readxl)
  library(readr)
})

# Optional packages: features degrade gracefully when absent
HAS_DRC      <- requireNamespace("drc", quietly = TRUE)       # IC50 fit + 95% CI
HAS_MULTCOMP <- requireNamespace("multcomp", quietly = TRUE)  # Dunnett test
HAS_RAGG     <- requireNamespace("ragg", quietly = TRUE)      # better PNG/TIFF export
