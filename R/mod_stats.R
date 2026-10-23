# mod_stats.R - StatsTest + RunStats. Uses raw (range + NA-dropped) data
# by default; tick the box to test the normalised/outlier-filtered data.

mod_stats_ui <- function(id) {
  ns <- NS(id)
  tagList(
    selectInput(ns("test"), "Test", choices = statsChoices, selected = "None"),
    checkboxInput(ns("usePre"), "Use preprocessed data (normalised / outlier-filtered)", value = FALSE),
    tags$small(class = "text-muted", "Group and Control are set in the Variables panel."),
    div(class = "mt-2",
        actionButton(ns("run"), "Run stats", icon = icon("calculator"), class = "btn-primary btn-sm"),
        downloadButton(ns("dl"), "Result CSV", class = "btn-sm btn-light")),
    verbatimTextOutput(ns("result"))
  )
}

mod_stats_server <- function(id, mapping, pipeline) {
  moduleServer(id, function(input, output, session) {
    resultRV <- reactiveVal(NULL)

    observeEvent(input$run, {
      pl <- tryCatch(pipeline(), error = function(e) NULL)
      if (is.null(pl)) {
        showNotification("Load data first", type = "warning")
        return()
      }
      df <- if (isTRUE(input$usePre)) pl$processed else pl$base
      mp <- mapping()
      res <- run_stat_test(df, input$test, mp$xVars, mp$yVars, mp$group, mp$control)
      res$text <- paste0(res$text, "\n\nData: ", if (isTRUE(input$usePre)) "preprocessed" else "raw (range + NA drop only)")
      resultRV(res)
      showModal(modalDialog(
        title = res$title %||% "Result",
        verbatimTextOutput(session$ns("modalText")),
        DT::DTOutput(session$ns("modalTable")),
        size = "l", easyClose = TRUE, footer = modalButton("Close")
      ))
    })

    output$result <- renderText({ req(resultRV()); resultRV()$text })
    output$modalText <- renderText({ req(resultRV()); resultRV()$text })
    output$modalTable <- DT::renderDT({
      req(resultRV())
      tab <- resultRV()$table
      req(!is.null(tab))
      num <- vapply(tab, is.numeric, logical(1))
      tab[num] <- lapply(tab[num], signif, 4)
      DT::datatable(tab, rownames = FALSE, options = list(scrollX = TRUE, dom = "tp"))
    })

    output$dl <- downloadHandler(
      filename = function() paste0("stats_result_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".csv"),
      content = function(file) {
        res <- resultRV()
        if (is.null(res)) {
          utils::write.csv(data.frame(Note = "Run a test first"), file, row.names = FALSE)
        } else if (!is.null(res$table)) {
          utils::write.csv(res$table, file, row.names = FALSE)
        } else {
          utils::write.csv(data.frame(Result = strsplit(res$text, "\n")[[1]]), file, row.names = FALSE)
        }
      }
    )
  })
}
