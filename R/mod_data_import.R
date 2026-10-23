# mod_data_import.R - ImportButton + FileListBox (+ demo data)

mod_data_import_ui <- function(id) {
  ns <- NS(id)
  tagList(
    fileInput(ns("files"), "Import Excel / CSV (multiple files allowed)", multiple = TRUE,
              accept = c(".csv", ".tsv", ".txt", ".xlsx", ".xls")),
    actionButton(ns("demo"), "Load demo data", icon = icon("flask"), class = "btn-sm btn-outline-primary mb-2"),
    selectInput(ns("fileList"), "Imported datasets", choices = character(0)),
    actionButton(ns("removeFile"), "Remove selected", icon = icon("trash"), class = "btn-sm btn-outline-danger")
  )
}

mod_data_import_server <- function(id, rv) {
  moduleServer(id, function(input, output, session) {

    add_dataset <- function(key, entry) {
      key <- utils::tail(make.unique(c(names(rv$dataStore), key)), 1)   # no silent overwrite
      store <- rv$dataStore
      store[[key]] <- entry
      rv$dataStore <- store
      rv$activeKey <- key
      updateSelectInput(session, "fileList", choices = names(store), selected = key)
    }

    observeEvent(input$files, {
      for (i in seq_len(nrow(input$files))) {
        nm <- input$files$name[i]
        entry <- tryCatch(read_dataset(input$files$datapath[i], nm),
                          error = function(e) {
                            showNotification(paste0("Import failed (", nm, "): ", conditionMessage(e)),
                                             type = "error", duration = 8)
                            NULL
                          })
        if (!is.null(entry)) add_dataset(tools::file_path_sans_ext(nm), entry)
      }
    })

    observeEvent(input$demo, add_dataset("Demo_data", make_demo_data()))

    observeEvent(input$fileList, {
      if (!is_none(input$fileList) && input$fileList %in% names(rv$dataStore)) rv$activeKey <- input$fileList
    }, ignoreInit = TRUE)

    observeEvent(input$removeFile, {
      req(rv$activeKey)
      store <- rv$dataStore
      store[[rv$activeKey]] <- NULL
      rv$dataStore <- store
      if (length(store) > 0) {
        rv$activeKey <- utils::tail(names(store), 1)
      } else {
        rv$activeKey <- NULL
        rv$sheetTable <- NULL
        rv$activeTable <- NULL
      }
      updateSelectInput(session, "fileList", choices = names(store), selected = rv$activeKey %||% character(0))
    })
  })
}
