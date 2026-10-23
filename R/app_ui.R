# app_ui.R - sidebar with collapsible sections + tabbed canvas

app_ui <- function() {
  page_sidebar(
    title = "Scientist Data Suite",
    theme = bs_theme(version = 5, bootswatch = "flatly"),
    fillable = TRUE,
    tags$head(tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")),
    sidebar = sidebar(
      width = 400,
      accordion(
        id = "side", multiple = TRUE,
        open = c("Data", "Variables", "Plot"),
        accordion_panel(
          "Data", icon = icon("file-import"),
          mod_data_import_ui("import"),
          mod_sheet_manager_ui("sheet"),
          div(class = "d-flex flex-wrap gap-2 mb-2",
              mod_data_preview_ui("preview"),
              mod_range_selector_ui("range")),
          mod_data_info_ui("preview")
        ),
        accordion_panel("Preprocessing", icon = icon("filter"), mod_preprocessing_ui("preproc")),
        accordion_panel("Variables", icon = icon("sliders"), mod_axis_mapping_ui("mapping")),
        accordion_panel("Plot", icon = icon("chart-line"), mod_viz_controls_ui("viz")),
        accordion_panel("Statistics", icon = icon("calculator"), mod_stats_ui("stats")),
        accordion_panel("Export", icon = icon("download"), mod_export_ui("export"))
      )
    ),
    mod_plot_canvas_ui("canvas")
  )
}
