# mod_preprocessing.R - NormDropDown + OutlierSpinner + drop NA
# Outlier filter is OFF by default so no data disappear silently.

mod_preprocessing_ui <- function(id) {
  ns <- NS(id)
  tagList(
    selectInput(ns("norm"), "Normalisation (Y)", choices = normChoices, selected = "None"),
    numericInput(ns("outlier"), "Outlier filter on first Y (SD threshold, 0 = off)",
                 value = 0, min = 0, max = 10, step = 0.5),
    checkboxInput(ns("dropNA"), "Drop rows with NA in selected X/Y", value = TRUE),
    tags$small(class = "text-muted",
               "Plots use these settings. Statistics use raw data unless you tick the option in the Statistics panel.")
  )
}

mod_preprocessing_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    reactive(list(norm = input$norm, outlier = input$outlier, dropNA = isTRUE(input$dropNA)))
  })
}
