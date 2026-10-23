# mod_axis_mapping.R - X/Y lists, Group, Control, Size, Colour, Colormap.
# Keeps your current selections when you switch sheet, if they still exist.

mod_axis_mapping_ui <- function(id) {
  ns <- NS(id)
  tagList(
    selectizeInput(ns("xVars"), "X variable(s)", choices = NULL, multiple = TRUE,
                   options = list(maxItems = 12, plugins = list("remove_button"))),
    selectizeInput(ns("yVars"), "Y variable(s) (numeric)", choices = NULL, multiple = TRUE,
                   options = list(maxItems = 12, plugins = list("remove_button"))),
    selectInput(ns("group"), "Group by (categorical)", choices = "None"),
    selectInput(ns("control"), "Control / reference group", choices = "None"),
    selectInput(ns("size"), "Bubble size (numeric, scatter)", choices = "None"),
    selectInput(ns("color"), "Bubble colour (numeric, scatter)", choices = "None"),
    selectInput(ns("cmap"), "Colour map", choices = cmapChoices, selected = "viridis")
  )
}

mod_axis_mapping_server <- function(id, rv) {
  moduleServer(id, function(input, output, session) {

    keep_sel <- function(current, pool, default) {
      current <- intersect(current %||% character(0), pool)
      if (length(current)) current else default
    }

    observeEvent(rv$activeTable, {
      df <- rv$activeTable
      cols <- names(df)
      num <- numeric_cols(df)
      few_levels <- vapply(df, function(v) length(unique(v)) <= 25, logical(1))
      cat_cols <- cols[!(cols %in% num) | few_levels]

      updateSelectizeInput(session, "xVars", choices = cols,
                           selected = keep_sel(isolate(input$xVars), cols, utils::head(num, 1)))
      y_default <- if (length(num) >= 2) num[2] else utils::head(num, 1)
      updateSelectizeInput(session, "yVars", choices = num,
                           selected = keep_sel(isolate(input$yVars), num, y_default))
      updateSelectInput(session, "group", choices = c("None", cat_cols),
                        selected = keep_sel(isolate(input$group), cat_cols, "None"))
      updateSelectInput(session, "size", choices = c("None", num),
                        selected = keep_sel(isolate(input$size), num, "None"))
      updateSelectInput(session, "color", choices = c("None", num),
                        selected = keep_sel(isolate(input$color), num, "None"))
    })

    observeEvent(list(input$group, rv$activeTable), {
      df <- rv$activeTable
      g <- input$group
      if (is.null(df) || is_none(g) || !g %in% names(df)) {
        updateSelectInput(session, "control", choices = "None", selected = "None")
      } else {
        lv <- levels(factor(df[[g]]))
        updateSelectInput(session, "control", choices = lv,
                          selected = keep_sel(isolate(input$control), lv, lv[1]))
      }
    }, ignoreNULL = FALSE)

    reactive(list(
      xVars = input$xVars %||% character(0),
      yVars = input$yVars %||% character(0),
      group = input$group %||% "None",
      control = input$control %||% "None",
      size = input$size %||% "None",
      color = input$color %||% "None",
      cmap = input$cmap %||% "viridis"
    ))
  })
}
