# mod_viz_controls.R - GraphType, Tiled/Overlay, MaxTiles, error bars,
# points, significance stars, font size

mod_viz_controls_ui <- function(id) {
  ns <- NS(id)
  tagList(
    selectInput(ns("plotType"), "Graph type", choices = plotTypeChoices, selected = PLOT_SCATTER),
    fluidRow(
      column(6, selectInput(ns("multiMode"), "Multi-variable layout", choices = multiPlotChoices)),
      column(6, numericInput(ns("maxTiles"), "Max panels", value = 9, min = 1, max = 36, step = 1))
    ),
    fluidRow(
      column(6, selectInput(ns("errType"), "Error bars", choices = errorChoices, selected = "SEM")),
      column(6, selectInput(ns("sigTest"), "Stars vs control", choices = sigChoices))
    ),
    checkboxInput(ns("showPoints"), "Show individual data points (bar/box)", value = TRUE),
    sliderInput(ns("base_size"), "Font size", min = 8, max = 20, value = 12, step = 1)
  )
}

mod_viz_controls_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    reactive(list(
      plotType = input$plotType,
      multiMode = input$multiMode,
      maxTiles = max(1, input$maxTiles %||% 9, na.rm = TRUE),
      errType = input$errType %||% "SEM",
      sigTest = input$sigTest %||% "None",
      showPoints = isTRUE(input$showPoints),
      base_size = input$base_size %||% 12
    ))
  })
}
