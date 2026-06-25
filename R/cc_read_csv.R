#' Read and Clean Trade Data From China Customs
#'
#' Reads one or more CSV files downloaded from China Customs
#' (\url{http://stats.customs.gov.cn/indexEn}) with the correct encoding and
#' column types, regardless of which columns are present, their order, or the
#' language (English, Chinese, or a mix across files). Column names are
#' harmonized to stable English snake_case names and the `yearmonth` column, if
#' present, is converted to a date.
#'
#' @details
#' China Customs exports vary in shape depending on the query: single-month
#' downloads omit the date column, and the set and order of columns depend on
#' which dimensions were selected and the chosen sort order. This function reads
#' each file according to its own header, so files of different shapes and
#' languages can be read in one call and row-bound together.
#'
#' The function emits warnings (rather than failing silently) for three common
#' problems:
#' \itemize{
#'   \item \strong{Truncation.} The download page silently truncates results at
#'     10,000 rows. A file with exactly 10,000 data rows may be incomplete.
#'   \item \strong{Wrong encoding.} If none of the column names match known
#'     China Customs variables, the file was probably saved in a different
#'     encoding than `encoding`.
#'   \item \strong{Unrecognized columns.} Columns not found in
#'     [cc_variable_names] are kept under their original name and read as text.
#' }
#'
#' Each line is expected to carry a trailing comma (as added by China Customs);
#' the resulting empty column is ignored.
#'
#' When several files are read at once, a warning is issued if they do not all
#' share the same columns, because the row-bind then fills the gaps with `NA`.
#'
#' One difference cannot be detected automatically: the **trade flow**. Imports,
#' exports and combined "import and export" downloads all have exactly the same
#' columns -- the direction is never recorded in the file. Reading an
#' imports-only file together with an exports-only file therefore merges the two
#' silently. If you need to keep them apart, add a column identifying the flow to
#' each file before binding, for example
#' `cc_read_csv("imports.csv") |> dplyr::mutate(flow = "import")`.
#'
#' @param paths Path to one or more CSV files downloaded from China Customs.
#'   Files can be in English, Chinese, or a mix of both.
#' @param drop_descriptions Keep only codes for commodity, partner country,
#'   province, and customs regime? Default is `TRUE` because the bundled
#'   descriptions are redundant and often contain spelling mistakes. Clean
#'   descriptions can be re-attached from [cc_commodities], [cc_partners] and
#'   [cc_regimes].
#' @param encoding Character encoding of the files. Defaults to `"GB18030"`, the
#'   encoding China Customs uses (a superset of GBK and GB2312). Override only if
#'   you re-saved a file in another encoding such as `"UTF-8"`.
#'
#' @return A tibble.
#' @export
#' @import dplyr
#' @import tidyr
#' @import readr
#'
#' @examples
#' # read a single bundled example file
#' path <- system.file("extdata", "english-full.csv", package = "chinautils")
#' if (nzchar(path)) cc_read_csv(path)
cc_read_csv <- function(paths, drop_descriptions = TRUE, encoding = "GB18030") {

  # define helper function for single file first, vectorize later
  read_single_csv <- function(path) {

    stopifnot(length(path) == 1L)

    # glimpse at first row to determine which columns are present and which language is used
    first_row <- read_csv(path,
                          n_max = 0L,
                          locale = locale(encoding = encoding),
                          col_types = cols(.default = col_character())) |>
      # trailing comma leads to empty column, ignore
      suppressMessages()

    raw_colnames <- colnames(first_row)

    # undecodable names almost always mean the file is not in `encoding`; bail
    # out early with a clear message rather than crashing later on mojibake
    if (any(!validUTF8(raw_colnames))) {
      cli::cli_abort(c(
        "Could not decode the column names in {.file {path}} as {.val {encoding}}.",
        "i" = "The file is probably saved in a different encoding. Set {.arg encoding} accordingly."
      ))
    }

    # trailing comma leads to an empty column starting with "...", ignore
    valid_colnames <- raw_colnames[!startsWith(raw_colnames, "...")]

    # decoding health check: if nothing matches the dictionary, the encoding is
    # likely wrong (e.g. a UTF-8 file decoded as GB18030 yields valid gibberish)
    known_names <- union(chinautils::cc_variable_names$en, chinautils::cc_variable_names$zh)
    if (!any(valid_colnames %in% known_names)) {
      cli::cli_warn(c(
        "None of the column names in {.file {path}} match known China Customs variables.",
        "i" = "The file may not be encoded as {.val {encoding}}; check the {.arg encoding} argument."
      ))
    }

    language <- if (any(stringr::str_detect(valid_colnames, "\\p{script=Han}"))) "zh" else "en"

    # find replacements for column names and their colspec (preserving order)
    lookup <- tibble::tibble(valid_colnames) |>
      left_join(chinautils::cc_variable_names,
                by = c("valid_colnames" = language),
                # multiple matches from Chinese due to spelling variations in English
                multiple = "any")

    # warn about columns we do not recognize (kept as-is, read as text)
    unmatched <- lookup$valid_colnames[is.na(lookup$clean_name)]
    if (length(unmatched) > 0) {
      cli::cli_warn(c(
        "Unrecognized {cli::qty(unmatched)} column{?s} in {.file {path}}.",
        "i" = "Kept under the original name and read as text: {.val {unmatched}}."
      ))
    }

    # fall back to original name / character type for unmatched columns
    clean_colnames <- coalesce(lookup$clean_name, lookup$valid_colnames)
    col_spec <- stringr::str_flatten(coalesce(lookup$col_type, "c"))

    out <- read_csv(
      file = path,
      na = "?",
      locale = locale(encoding = encoding),
      col_select = all_of(valid_colnames),
      col_types = col_spec
    ) |>
      # trailing comma leads to empty column, ignore
      suppressMessages()

    colnames(out) <- clean_colnames

    # the download page silently truncates at 10,000 rows
    if (nrow(out) == 10000L) {
      cli::cli_warn(c(
        "{.file {path}} has exactly 10,000 rows.",
        "i" = "China Customs truncates downloads at 10,000 rows; this file may be incomplete."
      ))
    }

    out
  }

  # vectorize
  parts <- purrr::map(paths, read_single_csv)

  # warn if the files do not share the same columns: row-binding fills the gaps
  # with NA, which is easy to miss (e.g. appending a single-month update, which
  # has no date column, to an existing multi-month series)
  if (length(parts) > 1) {
    colsets <- lapply(parts, colnames)
    inconsistent <- setdiff(Reduce(union, colsets), Reduce(intersect, colsets))
    if (length(inconsistent) > 0) {
      msg <- c(
        "The files do not all contain the same columns.",
        "i" = "Missing from at least one file and filled with {.val NA}: {.val {inconsistent}}."
      )
      if ("yearmonth" %in% inconsistent) {
        msg <- c(msg, "i" = paste(
          "A missing {.field yearmonth} is expected when a single-month download",
          "(which has no date column) is combined with other files. Set it",
          "manually if you know the month."
        ))
      }
      cli::cli_warn(msg)
    }
  }

  dat <- parts |> purrr::list_rbind()

  # drop redundant descriptions
  if (drop_descriptions) dat <- dat |> select(!ends_with("_name"))

  # convert yearmonth to date (absent in single-month downloads)
  if ("yearmonth" %in% colnames(dat)) {
    dat <- dat |> mutate(yearmonth = lubridate::ym(.data$yearmonth))
  }

  # sort
  dat |> arrange(across(any_of(c(
    "yearmonth",
    "partner",
    "province",
    "regime",
    "commodity"
  ))))
}
