# mod_range_selector.R - openRangeSelector. Non-destructive: the crop is
# always taken from the full sheet (rv$sheetTable), and Reset restores it.

mod_range_selector_ui <- function(id) {
  ns <- NS(id)
  tagList(
    actionButton(ns("open"), "Select range", icon = icon("crop"), class = "btn-sm btn-light"),
    actionButton(ns("reset"), "Reset", icon = icon("rotate-left"), class = "btn-sm btn-light")
  )
}

mod_range_selector_server <- function(id, rv) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    observeEvent(input$open, {
      req(rv$sheetTable)
      nr <- nrow(rv$sheetTable); nc <- ncol(rv$sheetTable)
      showModal(modalDialog(
        title = sprintf("Select data range (full sheet: %d rows x %d cols)", nr, nc),
        fluidRow(
          column(6, numericInput(ns("r1"), "Row start", 1, min = 1, max = nr)),
          column(6, numericInput(ns("r2"), "Row end", nr, min = 1, max = nr))
        ),
        fluidRow(
          column(6, numericInput(ns("c1"), "Column start", 1, min = 1, max = nc)),
          column(6, numericInput(ns("c2"), "Column end", nc, min = 1, max = nc))
        ),
        tags$small(paste("Columns:", paste(seq_len(nc), names(rv$sheetTable), sep = "=", collapse = ", "))),
        footer = tagList(modalButton("Cancel"), actionButton(ns("apply"), "Apply", class = "btn-primary")),
        size = "m"
      ))
    })

    observeEvent(input$apply, {
      req(rv$sheetTable)
      rv$activeTable <- apply_range_filter(rv$sheetTable, input$r1, input$r2, input$c1, input$c2)
      removeModal()
      showNotification(sprintf("Range applied: %d rows x %d cols", nrow(rv$activeTable), ncol(rv$activeTable)),
                       type = "message")
    })

    observeEvent(input$reset, {
      req(rv$sheetTable)
      rv$activeTable <- rv$sheetTable
      showNotification("Range reset to full sheet", type = "message")
    })
  })
}
