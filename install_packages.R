# Run once:  source("install_packages.R")
required <- c("shiny", "bslib", "DT", "plotly", "ggplot2", "readxl", "readr", "dplyr", "tidyr")
optional <- c("drc", "multcomp", "ragg")   # IC50 CI, Dunnett, better PNG/TIFF
pkgs <- c(required, optional)
missing <- pkgs[!vapply(pkgs, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing)) install.packages(missing) else message("All packages already installed.")
