# fct_data.R - reading, filtering, normalisation (replaces getVar,
# getGroup, getProcessedData, getSelectedXY)

read_dataset <- function(path, name) {
  ext <- tolower(tools::file_ext(name))
  if (ext %in% c("csv", "tsv", "txt")) {
    tbl <- if (ext == "csv") readr::read_csv(path, show_col_types = FALSE)
           else readr::read_tsv(path, show_col_types = FALSE)
    list(tables = list(as.data.frame(tbl)), sheets = "(single table)", path = name)
  } else if (ext %in% c("xlsx", "xls")) {
    sh <- readxl::excel_sheets(path)
    tbls <- lapply(sh, function(s) as.data.frame(readxl::read_excel(path, sheet = s)))
    names(tbls) <- sh
    list(tables = tbls, sheets = sh, path = name)
  } else {
    user_stop("Unsupported file type '.", ext, "' (use .csv, .tsv, .xlsx or .xls)")
  }
}

apply_range_filter <- function(df, r1, r2, c1, c2) {
  as_int <- function(v, default) {
    v <- suppressWarnings(as.integer(v))
    if (length(v) == 0 || is.na(v)) default else v
  }
  r1 <- max(1, min(as_int(r1, 1), nrow(df)))
  r2 <- max(r1, min(as_int(r2, nrow(df)), nrow(df)))
  c1 <- max(1, min(as_int(c1, 1), ncol(df)))
  c2 <- max(c1, min(as_int(c2, ncol(df)), ncol(df)))
  df[r1:r2, c1:c2, drop = FALSE]
}

drop_na_rows <- function(df, cols) {
  cols <- intersect(cols, names(df))
  if (length(cols) == 0) return(df)
  df[stats::complete.cases(df[, cols, drop = FALSE]), , drop = FALSE]
}

# Returns list(df, removed). sd_thresh = 0 means OFF.
apply_outlier_filter <- function(df, yVar, sd_thresh) {
  out <- list(df = df, removed = 0L)
  sd_thresh <- suppressWarnings(as.numeric(sd_thresh))
  if (length(sd_thresh) == 0 || is.na(sd_thresh) || sd_thresh <= 0) return(out)
  if (is_none(yVar) || !yVar %in% names(df) || !is.numeric(df[[yVar]])) return(out)
  y <- df[[yVar]]
  if (sum(!is.na(y)) < 4) return(out)
  mu <- mean(y, na.rm = TRUE); sg <- stats::sd(y, na.rm = TRUE)
  if (is.na(sg) || sg == 0) return(out)
  keep <- is.na(y) | abs(y - mu) <= sd_thresh * sg
  list(df = df[keep, , drop = FALSE], removed = sum(!keep))
}

# Returns list(df, note)
apply_normalization <- function(df, yVars, method) {
  note <- NULL
  if (is.null(method) || method == "None" || length(yVars) == 0) return(list(df = df, note = note))
  for (yn in keep_numeric(df, yVars)) {
    y <- df[[yn]]
    if (method == "Z-score (Y)") {
      mu <- mean(y, na.rm = TRUE); sg <- stats::sd(y, na.rm = TRUE)
      if (!is.na(sg) && sg > 0) df[[yn]] <- (y - mu) / sg
    } else if (method == "Min-Max (Y)") {
      rng <- range(y, na.rm = TRUE)
      if (all(is.finite(rng)) && diff(rng) > 0) df[[yn]] <- (y - rng[1]) / diff(rng)
    } else if (method == "Log2 (Y+1)") {
      bad <- sum(y <= -1, na.rm = TRUE)
      if (bad > 0) note <- c(note, sprintf("%s: %d value(s) <= -1 set to NA by log2", yn, bad))
      y[!is.na(y) & y <= -1] <- NA
      df[[yn]] <- log2(y + 1)
    }
  }
  list(df = df, note = note)
}

# Built-in example data so every plot type can be tried immediately
make_demo_data <- function() {
  set.seed(42)
  doses <- c(0.001, 0.01, 0.1, 1, 10, 100)
  dose <- expand.grid(Dose_uM = doses, Replicate = 1:3,
                      Drug = c("Drug_A", "Drug_B"), stringsAsFactors = FALSE)
  ic <- ifelse(dose$Drug == "Drug_A", 0.5, 5)
  dose$Viability_pct <- 5 + 95 / (1 + (dose$Dose_uM / ic)^1.2) + stats::rnorm(nrow(dose), 0, 4)

  groups <- data.frame(
    Treatment = rep(c("Control", "siRNA_1", "siRNA_2", "Drug"), each = 6),
    Expression = c(stats::rnorm(6, 1, 0.15), stats::rnorm(6, 0.55, 0.12),
                   stats::rnorm(6, 0.6, 0.15), stats::rnorm(6, 1.4, 0.2)),
    Secretion = c(stats::rnorm(6, 10, 1.5), stats::rnorm(6, 6, 1.2),
                  stats::rnorm(6, 7, 1.5), stats::rnorm(6, 13, 2)),
    Cell_size = stats::rnorm(24, 20, 3),
    stringsAsFactors = FALSE
  )

  tt <- rep(c(0, 2, 4, 8, 12, 24), each = 3)
  timecourse <- data.frame(
    Time_h = tt,
    Signal_A = 100 * (1 - exp(-tt / 5)) + stats::rnorm(length(tt), 0, 5),
    Signal_B = 80 * exp(-tt / 10) + stats::rnorm(length(tt), 0, 4)
  )

  list(tables = list(dose_response = dose, groups = groups, timecourse = timecourse),
       sheets = c("dose_response", "groups", "timecourse"),
       path = "Demo data")
}
