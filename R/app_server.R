# app_server.R - wires shared state and all modules

app_server <- function(input, output, session) {
  rv <- reactiveValues(
    dataStore = list(),   # all imported files
    activeKey = NULL,     # selected file
    sheetTable = NULL,    # full selected sheet
    activeTable = NULL    # sheet after optional range crop
  )

  mod_data_import_server("import", rv)
  mod_sheet_manager_server("sheet", rv)
  mod_data_preview_server("preview", rv)
  mod_range_selector_server("range", rv)

  preproc <- mod_preprocessing_server("preproc")
  mapping <- mod_axis_mapping_server("mapping", rv)
  viz     <- mod_viz_controls_server("viz")

  canvas <- mod_plot_canvas_server("canvas", rv, preproc, mapping, viz)

  mod_stats_server("stats", mapping, canvas$pipeline)
  mod_export_server("export", canvas$plotResult, canvas$pipeline)
}
