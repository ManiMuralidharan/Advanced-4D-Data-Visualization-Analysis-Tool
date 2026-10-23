# fct_ic50.R - 4-parameter logistic fit (replaces MATLAB nlinfit)
# Model: Bottom + (Top - Bottom) / (1 + (x / IC50)^Hill)

fourPL <- function(x, top, ic50, hill, bottom) {
  bottom + (top - bottom) / (1 + (x / ic50)^hill)
}

.fit_drc <- function(d) {
  m <- drc::drm(y ~ x, data = d, fct = drc::LL.4(names = c("hill", "bottom", "top", "ic50")))
  co <- unname(stats::coef(m))
  ci <- tryCatch({
    ed <- suppressWarnings(drc::ED(m, 50, interval = "delta", display = FALSE))
    c(ed[1, "Lower"], ed[1, "Upper"])
  }, error = function(e) c(NA_real_, NA_real_))
  list(hill = co[1], bottom = co[2], top = co[3], ic50 = co[4],
       ic50_lo = unname(ci[1]), ic50_hi = unname(ci[2]), method = "drc LL.4")
}

.fit_nls <- function(d) {
  # Fit log10(IC50) for numerical stability
  start <- list(top = max(d$y), bottom = min(d$y), logic50 = stats::median(log10(d$x)), hill = 1)
  if (stats::cor(log10(d$x), d$y) > 0) start$hill <- -1   # rising curve
  fit <- tryCatch(
    stats::nls(y ~ bottom + (top - bottom) / (1 + 10^((log10(x) - logic50) * hill)),
               data = d, start = start, control = stats::nls.control(maxiter = 500)),
    error = function(e) NULL)
  if (is.null(fit)) user_stop("4PL fit did not converge (check that the data span the full curve)")
  co <- stats::coef(fit)
  se <- tryCatch(summary(fit)$coefficients["logic50", "Std. Error"], error = function(e) NA)
  tq <- stats::qt(0.975, max(1, nrow(d) - 4))
  list(hill = unname(co["hill"]), bottom = unname(co["bottom"]), top = unname(co["top"]),
       ic50 = unname(10^co["logic50"]),
       ic50_lo = unname(10^(co["logic50"] - tq * se)), ic50_hi = unname(10^(co["logic50"] + tq * se)),
       method = "nls 4PL")
}

fit_ic50 <- function(x, y) {
  ok <- is.finite(x) & is.finite(y) & x > 0          # single mask, x and y stay aligned
  d <- data.frame(x = x[ok], y = y[ok])
  if (nrow(d) < 4) user_stop("Need at least 4 points with X > 0")
  if (length(unique(d$x)) < 4) user_stop("Need at least 4 distinct doses")
  res <- if (HAS_DRC) tryCatch(.fit_drc(d), error = function(e) NULL) else NULL
  if (is.null(res)) res <- .fit_nls(d)
  pred <- fourPL(d$x, res$top, res$ic50, res$hill, res$bottom)
  res$r2 <- 1 - sum((d$y - pred)^2) / sum((d$y - mean(d$y))^2)
  res$n <- nrow(d)
  res$data <- d
  res
}

# One fit per group (or a single "All" fit). Returns list(fits, table)
fit_ic50_groups <- function(df, xVar, yVar, groupVar) {
  if (is_none(groupVar) || !groupVar %in% names(df)) {
    parts <- list(All = df)
  } else {
    parts <- split(df, factor(df[[groupVar]]))
  }
  fits <- lapply(names(parts), function(g) {
    r <- tryCatch(fit_ic50(as.numeric(parts[[g]][[xVar]]), as.numeric(parts[[g]][[yVar]])),
                  error = function(e) list(error = conditionMessage(e)))
    r$group <- g
    r
  })
  table <- do.call(rbind, lapply(fits, function(f) {
    if (!is.null(f$error)) {
      return(data.frame(Group = f$group, IC50 = NA, CI95_low = NA, CI95_high = NA, Hill = NA,
                        Top = NA, Bottom = NA, R2 = NA, n = NA, Method = NA, Note = f$error))
    }
    data.frame(Group = f$group, IC50 = signif(f$ic50, 4), CI95_low = signif(f$ic50_lo, 4),
               CI95_high = signif(f$ic50_hi, 4), Hill = signif(f$hill, 3), Top = signif(f$top, 4),
               Bottom = signif(f$bottom, 4), R2 = round(f$r2, 4), n = f$n, Method = f$method, Note = "")
  }))
  list(fits = fits, table = table)
}
