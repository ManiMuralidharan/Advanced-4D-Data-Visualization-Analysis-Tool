# mod_plot_canvas.R - data pipeline + central renderer
# One reactive builds the ggplot; the screen (plotly) and the export
# (ggsave) both use that same object, so they always match.

mod_plot_canvas_ui <- function(id) {
  ns <- NS(id)
  navset_card_tab(
    full_screen = TRUE,
    nav_panel("Plot",
              plotlyOutput(ns("mainPlot"), height = "640px"),
              div(class = "status-line", verbatimTextOutput(ns("status")))),
    nav_panel("Summary / fit table", DT::DTOutput(ns("fitTable"))),
    nav_panel("Processed data", DT::DTOutput(ns("dataTable")))
  )
}

mod_plot_canvas_server <- function(id, rv, preproc, mapping, viz) {
  moduleServer(id, function(input, output, session) {

    # base = range + NA drop (used by stats); processed = + outliers + normalisation (used by plots)
    pipeline <- reactive({
      validate(need(!is.null(rv$activeTable), "Import a file or click 'Load demo data' to start."))
      df <- rv$activeTable
      mp <- mapping(); pp <- preproc()
      n0 <- nrow(df)
      if (pp$dropNA) df <- drop_na_rows(df, c(mp$xVars, mp$yVars))
      na_dropped <- n0 - nrow(df)
      out <- apply_outlier_filter(df, if (length(mp$yVars)) mp$yVars[1] else NULL, pp$outlier)
      nrm <- apply_normalization(out$df, mp$yVars, pp$norm)
      list(base = df, processed = nrm$df,
           info = list(na_dropped = na_dropped, outliers = out$removed, norm = pp$norm, note = nrm$note))
    })

    plotResult <- reactive({
      pl <- pipeline()
      df <- pl$processed
      mp <- mapping(); vz <- viz()
      validate(need(nrow(df) > 0, "No rows left after preprocessing."))
      validate(need(length(mp$yVars) > 0, "Select at least one Y variable."))
      validate(need(vz$plotType %in% PLOTS_NO_X || length(mp$xVars) > 0, "Select an X variable."))
      res <- tryCatch(build_plot(df, mp, vz), error = function(e) e)
      if (inherits(res, "error")) validate(need(FALSE, conditionMessage(res)))
      res
    })

    output$mainPlot <- renderPlotly({
      p <- plotResult()$plot
      ggplotly(p) %>%
        config(displaylogo = FALSE,
               toImageButtonOptions = list(format = "svg", filename = "scientist_plot"))
    })

    output$status <- renderText({
      pl <- pipeline()
      i <- pl$info
      cap <- tryCatch(plotResult()$plot$labels$caption, error = function(e) NULL)
      paste(c(
        sprintf("%d rows plotted | NA rows dropped: %d | outliers removed: %d | normalisation: %s",
                nrow(pl$processed), i$na_dropped, i$outliers, i$norm),
        i$note,
        cap
      ), collapse = "\n")
    })

    output$fitTable <- DT::renderDT({
      tab <- plotResult()$table
      validate(need(!is.null(tab), "This plot type has no summary table (bar, box and IC50 plots do)."))
      DT::datatable(tab, rownames = FALSE, extensions = "Buttons",
                    options = list(dom = "Bfrtip", buttons = c("copy", "csv"), scrollX = TRUE, pageLength = 25))
    })

    output$dataTable <- DT::renderDT({
      DT::datatable(pipeline()$processed, options = list(scrollX = TRUE, pageLength = 15))
    })

    list(pipeline = pipeline, plotResult = plotResult)
  })
}
