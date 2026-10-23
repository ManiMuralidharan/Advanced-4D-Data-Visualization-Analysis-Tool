# fct_plotting.R - shared helpers for plots + the plot dispatcher

# Long table for plots that compare groups: .variable, .g, .y
build_group_long <- function(df, yVars, group, control = NULL) {
  g <- if (is_none(group) || !group %in% names(df)) factor(rep("All", nrow(df))) else factor(df[[group]])
  if (!is_none(control) && control %in% levels(g)) g <- stats::relevel(g, ref = control)
  long <- do.call(rbind, lapply(yVars, function(v) {
    data.frame(.variable = pretty_label(v), .g = g, .y = as.numeric(df[[v]]), stringsAsFactors = FALSE)
  }))
  long <- long[!is.na(long$.g) & is.finite(long$.y), , drop = FALSE]
  long$.variable <- factor(long$.variable, levels = unique(pretty_label(yVars)))
  long$.g <- droplevels(long$.g)
  long
}

# Long table for X/Y panel plots: .variable, .x, .y
build_xy_long <- function(df, xs, ys, labels) {
  long <- do.call(rbind, Map(function(x, y, l) {
    data.frame(.variable = l, .x = as.numeric(df[[x]]), .y = as.numeric(df[[y]]), stringsAsFactors = FALSE)
  }, xs, ys, labels))
  long <- long[is.finite(long$.x) & is.finite(long$.y), , drop = FALSE]
  long$.variable <- factor(long$.variable, levels = unique(labels))
  long
}

summarise_groups <- function(long, errType = "SEM") {
  long %>%
    group_by(.variable, .g) %>%
    summarise(mean = mean(.y), sd = stats::sd(.y), n = dplyr::n(), .groups = "drop") %>%
    mutate(sem = sd / sqrt(n),
           ci95 = ifelse(n > 1, stats::qt(0.975, pmax(n - 1, 1)) * sem, NA_real_),
           err = switch(errType, "SD" = sd, "SEM" = sem, "95% CI" = ci95, NA_real_))
}

# Each group vs the control, BH-adjusted within each variable
compute_sig <- function(long, control, method) {
  out <- list()
  for (v in levels(long$.variable)) {
    d <- long[long$.variable == v, , drop = FALSE]
    ctrl <- d$.y[d$.g == control]
    if (length(ctrl) < 2) next
    for (g in setdiff(levels(d$.g), control)) {
      trt <- d$.y[d$.g == g]
      p <- tryCatch(
        if (method == "Welch t-test") stats::t.test(trt, ctrl)$p.value
        else stats::wilcox.test(trt, ctrl, exact = FALSE)$p.value,
        error = function(e) NA_real_)
      out[[length(out) + 1]] <- data.frame(.variable = v, .g = g, p = p, stringsAsFactors = FALSE)
    }
  }
  if (!length(out)) return(NULL)
  res <- do.call(rbind, out)
  res$p_adj <- stats::ave(res$p, res$.variable, FUN = function(p) stats::p.adjust(p, "BH"))
  res$label <- p_to_stars(res$p_adj)
  res
}

# Adds star labels above each group. summ may be NULL (box plots).
add_sig_layer <- function(p, long, summ, group, sigTest, control, base_size) {
  if (is.null(sigTest) || sigTest == "None" || is_none(group)) return(p)
  if (is_none(control) || !control %in% levels(long$.g)) {
    return(p + labs(caption = "Significance: choose a Control group in the Variables panel"))
  }
  sig <- compute_sig(long, control, sigTest)
  if (is.null(sig)) return(p + labs(caption = "Significance: control group needs >= 2 values"))

  tops <- long %>% group_by(.variable, .g) %>% summarise(top = max(.y), .groups = "drop")
  if (!is.null(summ)) {
    s2 <- summ %>% mutate(top2 = mean + ifelse(is.na(err), 0, err)) %>% select(.variable, .g, top2)
    tops <- left_join(tops, s2, by = c(".variable", ".g")) %>% mutate(top = pmax(top, top2, na.rm = TRUE))
  }
  span <- long %>% group_by(.variable) %>% summarise(span = diff(range(c(0, .y))), .groups = "drop")
  sig$.variable <- factor(sig$.variable, levels = levels(long$.variable))
  sig$.g <- factor(sig$.g, levels = levels(long$.g))
  lab <- sig %>%
    left_join(tops, by = c(".variable", ".g")) %>%
    left_join(span, by = ".variable") %>%
    mutate(ypos = top + 0.08 * span)

  p + geom_text(data = lab, aes(x = .g, y = ypos, label = label), inherit.aes = FALSE,
                size = base_size / 3, vjust = 0) +
    labs(caption = sprintf("Stars: %s vs %s, BH-adjusted (* p<0.05, ** p<0.01, *** p<0.001, **** p<0.0001)",
                           sigTest, control))
}

# Dispatcher: returns list(plot = ggplot, table = data.frame or NULL)
build_plot <- function(df, mp, vz) {
  bs <- vz$base_size %||% 12
  mt <- vz$maxTiles %||% 9
  res <- if (vz$plotType == PLOT_SCATTER) {
    plot_scatter_4d(df, mp$xVars[1], mp$yVars[1], mp$group, mp$size, mp$color, mp$cmap, bs)
  } else if (vz$plotType == PLOT_MULTI_X) {
    plot_multi_x(df, mp$xVars, mp$yVars[1], vz$multiMode, mt, bs)
  } else if (vz$plotType == PLOT_MULTI_Y) {
    plot_multi_y(df, mp$xVars[1], mp$yVars, vz$multiMode, mt, bs)
  } else if (vz$plotType == PLOT_LINE) {
    plot_line(df, mp$xVars[1], mp$yVars, vz$multiMode, mt, bs, vz$errType)
  } else if (vz$plotType == PLOT_BAR) {
    plot_bar(df, mp$yVars, mp$group, vz$errType, vz$showPoints, vz$sigTest, mp$control, bs, mt)
  } else if (vz$plotType == PLOT_BOX) {
    plot_box(df, mp$yVars, mp$group, vz$showPoints, vz$sigTest, mp$control, bs, mt)
  } else if (vz$plotType == PLOT_HEATMAP) {
    plot_heatmap(df, mp$yVars, mp$cmap, bs)
  } else if (vz$plotType == PLOT_IC50) {
    plot_ic50(df, mp$xVars[1], mp$yVars[1], mp$group, bs)
  } else {
    user_stop("Unknown plot type")
  }
  if (inherits(res, "ggplot")) res <- list(plot = res, table = NULL)
  res
}
