# mod_export.R - publication export via ggsave (true PNG/TIFF/PDF files)

mod_export_ui <- function(id) {
  ns <- NS(id)
  tagList(
    selectInput(ns("format"), "Format", choices = exportChoices, selected = "png"),
    fluidRow(
      column(4, numericInput(ns("w"), "Width (mm)", 180, min = 30, max = 500)),
      column(4, numericInput(ns("h"), "Height (mm)", 120, min = 30, max = 500)),
      column(4, numericInput(ns("dpi"), "DPI", 300, min = 72, max = 1200))
    ),
    downloadButton(ns("plot"), "Export plot", class = "btn-sm btn-primary"),
    downloadButton(ns("table"), "Summary table", class = "btn-sm btn-light"),
    downloadButton(ns("data"), "Processed data", class = "btn-sm btn-light")
  )
}

save_plot_file <- function(p, file, format, w, h, dpi) {
  if (format == "png") {
    dev <- if (HAS_RAGG) ragg::agg_png else "png"
    ggsave(file, p, device = dev, width = w, height = h, units = "mm", dpi = dpi, bg = "white")
  } else if (format == "tiff") {
    dev <- if (HAS_RAGG) ragg::agg_tiff else "tiff"
    ggsave(file, p, device = dev, width = w, height = h, units = "mm", dpi = dpi,
           bg = "white", compression = "lzw")
  } else {
    dev <- if (isTRUE(capabilities("cairo"))) grDevices::cairo_pdf else "pdf"
    ggsave(file, p, device = dev, width = w, height = h, units = "mm")
  }
}

mod_export_server <- function(id, plotResult, pipeline) {
  moduleServer(id, function(input, output, session) {
    stamp <- function() format(Sys.time(), "%Y%m%d_%H%M%S")

    output$plot <- downloadHandler(
      filename = function() paste0("scientist_plot_", stamp(), ".", input$format),
      content = function(file) {
        p <- plotResult()$plot
        save_plot_file(p, file, input$format, input$w %||% 180, input$h %||% 120, input$dpi %||% 300)
      }
    )

    output$table <- downloadHandler(
      filename = function() paste0("summary_table_", stamp(), ".csv"),
      content = function(file) {
        tab <- plotResult()$table
        if (is.null(tab)) tab <- data.frame(Note = "This plot type has no summary table")
        utils::write.csv(tab, file, row.names = FALSE)
      }
    )

    output$data <- downloadHandler(
      filename = function() paste0("processed_data_", stamp(), ".csv"),
      content = function(file) utils::write.csv(pipeline()$processed, file, row.names = FALSE)
    )
  })
}
