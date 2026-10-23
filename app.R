# =====================================================================
# Scientist Data Suite (Shiny port of the MATLAB app)
#
# Run from R / RStudio:
#   shiny::runApp("ScientistDataSuite")      # path to THIS folder
# or open this file in RStudio and click "Run App".
#
# This file only loads the code in R/ in a fixed order, then starts
# the app. All logic lives in the R/ folder (see README.md).
# =====================================================================

# We source R/ ourselves (in a fixed order, including R/plots/),
# so switch off Shiny's automatic loading to avoid double-sourcing.
options(shiny.autoload.r = FALSE)

local({
  r_files <- list.files("R", pattern = "\\.[Rr]$", recursive = TRUE, full.names = TRUE)
  r_files <- sort(r_files)   # 00_packages.R and 01_constants.R load first
  for (f in r_files) source(f, local = globalenv())
})

shiny::shinyApp(ui = app_ui(), server = app_server)
