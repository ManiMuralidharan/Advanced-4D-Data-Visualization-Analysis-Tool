# mod_sheet_manager.R - SheetDropDown. Selecting a sheet resets any range crop.

mod_sheet_manager_ui <- function(id) {
  ns <- NS(id)
  selectInput(ns("sheet"), "Sheet", choices = character(0))
}

mod_sheet_manager_server <- function(id, rv) {
  moduleServer(id, function(input, output, session) {

    set_sheet <- function(idx) {
      entry <- rv$dataStore[[rv$activeKey]]
      if (is.null(entry) || idx > length(entry$tables)) return()
      rv$sheetTable  <- entry$tables[[idx]]
      rv$activeTable <- entry$tables[[idx]]
    }

    observeEvent(rv$activeKey, {
      req(rv$activeKey %in% names(rv$dataStore))
      sheets <- rv$dataStore[[rv$activeKey]]$sheets
      updateSelectInput(session, "sheet", choices = sheets, selected = sheets[1])
      set_sheet(1)
    })

    observeEvent(input$sheet, {
      req(rv$activeKey %in% names(rv$dataStore), !is_none(input$sheet))
      idx <- match(input$sheet, rv$dataStore[[rv$activeKey]]$sheets)
      req(!is.na(idx))
      set_sheet(idx)
    }, ignoreInit = TRUE)
  })
}
