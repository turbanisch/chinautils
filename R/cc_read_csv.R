#' Read and Clean Trade Data From China Customs
#'
#' This is a function to read CSV files downloaded from China Customs with the correct encoding and column type specification, no matter which columns are present in the data, their order and the language. The function harmonizes column names between English and Chinese files, converts dates and adds an ISO3 identifier for Chinese provinces.
#'
#' Note that this function does not perform any sanity checks on the data, so make sure no individual CSV file was cut off after 10,000 lines. The function expects (and ignores) a trailing comma in each line of the CSV file which is normally added by China Customs. The order of columns has to be the same across files.
#'
#' @param file Path to one or multiple CSV files downloaded from China Customs. Files can be in English, Chinese, or a mix of both.
#' @param drop_descriptions Keep only codes for commodity, partner country, province, and customs regime? Default is `TRUE` because descriptions are redundant and often include spelling mistakes.
#'
#' @return A tibble
#' @export
#' @import dplyr
#' @import tidyr
#' @import readr
cc_read_csv <- function(paths,  drop_descriptions = TRUE) {
  # glimpse at first row to determine which columns are present and which language is used
  first_row <- read_csv(paths[1],
                        n_max = 0L,
                        locale = locale(encoding = "GB18030"),
                        col_types = cols(.default = col_character()))

    valid_colnames <- colnames(first_row %>% select(!starts_with("...")))
    language <- if (any(stringr::str_detect(valid_colnames, "\\p{script=Han}"))) "zh" else "en"

    # get list of colnames to replace (preserving their order)
    clean_colnames <- tibble(valid_colnames) %>%
      left_join(chinautils::cc_variable_names, by = c("valid_colnames" = language)) %>%
      pull(clean_name)

    # get specification of column types
    col_spec <- tibble(valid_colnames) %>%
      left_join(chinautils::cc_variable_names, by = c("valid_colnames" = language)) %>%
      pull(col_type) %>%
      stringr::str_c(collapse = "")

    # read all files
    dat <- read_csv(
      file = paths,
      na = "?",
      locale = locale(encoding = "GB18030"),
      col_select = 1:length(valid_colnames),
      col_types = col_spec,
      col_names = clean_colnames,
      skip = 1L
    )

    # drop redundant descriptions
    if (drop_descriptions)
      dat <- dat %>% select(!ends_with("_name"))

    # convert yearmonth to date
    dat <- dat %>% mutate(yearmonth = lubridate::ym(yearmonth))

    # sort
    dat %>% arrange(across(any_of(c(
      "yearmonth",
      "partner",
      "province",
      "regime",
      "commodity"
    ))))
}
