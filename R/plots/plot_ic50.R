# plot_ic50.R - 4PL curves on log X, one curve per group if Group By is set
# Returns list(plot, table = IC50 parameters with 95% CI)

plot_ic50 <- function(df, xVar, yVar, group, base_size = 12) {
  if (is_none(xVar) || !xVar %in% names(df)) user_stop("Select X (dose / concentration)")
  if (is_none(yVar) || !yVar %in% names(df)) user_stop("Select Y (response)")
  if (!is.numeric(df[[xVar]]) || !is.numeric(df[[yVar]])) user_stop("X and Y must both be numeric for IC50 fitting")

  useGroup <- !is_none(group) && group %in% names(df)
  fit <- fit_ic50_groups(df, xVar, yVar, if (useGroup) group else NULL)
  grp_levels <- vapply(fit$fits, function(f) f$group, character(1))

  pts <- data.frame(.x = df[[xVar]], .y = df[[yVar]],
                    .g = if (useGroup) as.character(df[[group]]) else "All", stringsAsFactors = FALSE)
  pts <- pts[is.finite(pts$.x) & is.finite(pts$.y) & pts$.x > 0 & !is.na(pts$.g), , drop = FALSE]
  if (!nrow(pts)) user_stop("No points with X > 0 (log scale needs positive doses)")
  pts$.g <- factor(pts$.g, levels = grp_levels)

  ok_fits <- Filter(function(f) is.null(f$error), fit$fits)
  curves <- do.call(rbind, lapply(ok_fits, function(f) {
    xs <- 10^seq(log10(min(f$data$x)), log10(max(f$data$x)), length.out = 200)
    data.frame(.g = f$group, .x = xs, .y = fourPL(xs, f$top, f$ic50, f$hill, f$bottom))
  }))
  ic_lines <- do.call(rbind, lapply(ok_fits, function(f) data.frame(.g = f$group, ic50 = f$ic50)))

  cap <- paste(vapply(fit$fits, function(f) {
    if (!is.null(f$error)) return(sprintf("%s: fit failed (%s)", f$group, f$error))
    ci <- if (is.na(f$ic50_lo)) "" else sprintf(" [95%% CI %s to %s]", fmt_num(f$ic50_lo), fmt_num(f$ic50_hi))
    sprintf("%s: IC50 = %s%s, Hill = %s, R2 = %.3f", f$group, fmt_num(f$ic50), ci, fmt_num(f$hill), f$r2)
  }, character(1)), collapse = "\n")

  n <- length(grp_levels)
  p <- ggplot(pts, aes(.x, .y, colour = .g)) + geom_point(size = 2, alpha = 0.85)
  if (!is.null(curves)) {
    curves$.g <- factor(curves$.g, levels = grp_levels)
    ic_lines$.g <- factor(ic_lines$.g, levels = grp_levels)
    p <- p + geom_line(data = curves, linewidth = 0.9) +
      geom_vline(data = ic_lines, aes(xintercept = ic50, colour = .g), linetype = "dashed", linewidth = 0.4)
  }
  p <- p + scale_x_log10() +
    scale_colour_manual(values = cat_pal(n), name = if (useGroup) pretty_label(group) else NULL, drop = FALSE) +
    labs(x = pretty_label(xVar), y = pretty_label(yVar), caption = cap) +
    theme_pub(base_size)
  if (!useGroup) p <- p + theme(legend.position = "none")
  list(plot = p, table = fit$table)
}
