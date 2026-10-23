# mod_data_preview.R - showPreview modal + row/col info + column types

mod_data_preview_ui <- function(id) {
  ns <- NS(id)
  actionButton(ns("show"), "Preview", icon = icon("table"), class = "btn-sm btn-light")
}

mod_data_info_ui <- function(id) {
  ns <- NS(id)
  div(class = "data-info", textOutput(ns("info")))
}

mod_data_preview_server <- function(id, rv) {
  moduleServer(id, function(input, output, session) {
    output$info <- renderText({
      if (is.null(rv$activeTable)) return("No data loaded")
      cropped <- !identical(dim(rv$activeTable), dim(rv$sheetTable))
      sprintf("Rows: %d | Cols: %d | Numeric cols: %d%s", nrow(rv$activeTable), ncol(rv$activeTable),
              length(numeric_cols(rv$activeTable)), if (cropped) " | range applied" else "")
    })

    observeEvent(input$show, {
      req(rv$activeTable)
      showModal(modalDialog(
        title = "Data preview (first 200 rows)",
        DT::DTOutput(session$ns("table")),
        tags$h6("Column types", class = "mt-3"),
        DT::DTOutput(session$ns("types")),
        size = "xl", easyClose = TRUE, footer = modalButton("Close")
      ))
    })

    output$table <- DT::renderDT({
      req(rv$activeTable)
      DT::datatable(utils::head(rv$activeTable, 200), options = list(scrollX = TRUE, pageLength = 10))
    })

    output$types <- DT::renderDT({
      req(rv$activeTable)
      df <- rv$activeTable
      DT::datatable(data.frame(
        Column = names(df),
        Type = vapply(df, function(v) class(v)[1], character(1)),
        Missing = vapply(df, function(v) sum(is.na(v)), integer(1)),
        Unique = vapply(df, function(v) length(unique(v)), integer(1))
      ), rownames = FALSE, options = list(dom = "tp", pageLength = 10))
    })
  })
}
