#' Read and Clean Trade Data From China Customs
#'
#' This is a function to read CSV files downloaded from China Customs with the correct encoding and column type specification. It expects data that was queried by month across the four dimensions commodity, partner country, province, and customs regime. The function harmonizes column names between English and Chinese files, converts dates and adds an ISO3 identifier for Chinese provinces.
#'
#' Note that this function does not perform any sanity checks on the data, so make sure no individual CSV file was cut off after 10,000 lines. The function expects (and ignores) a trailing comma in each line of the CSV file which is normally added by China Customs.
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
    chinese <- any(str_detect(valid_colnames, "\\p{script=Han}"))

    # get list of colnames to replace
    if (chinese) {
      clean_colnames <- chinautils::cc_variable_names %>%
        filter(zh %in% valid_colnames) %>%
        pull(clean_name)
    } else {
      clean_colnames <- chinautils::cc_variable_names %>%
        filter(en %in% valid_colnames) %>%
        pull(clean_name)
    }

    # read all files
    dat <- read_csv(
      file = paths,
      na = "?",
      locale = locale(encoding = "GB18030"),
      col_select = 1:length(valid_colnames),
      col_types = cols(
        .default = col_character(),
        quantity_1 = col_double(),
        quantity_2 = col_double(),
        value = col_number()
      ),
      col_names = clean_colnames,
      skip = 1L
    )

    # drop redundant descriptions
    if (drop_descriptions)
      dat <- dat %>% select(!ends_with("_name"))

    # convert yearmonth to date
    dat <- dat %>% mutate(yearmonth = lubridate::ym(yearmonth))

    # convert province code to ISO
    dat <-
      dat %>% mutate(
        province = chinautils::provincename(province, origin = "china_customs")
      )

    # sort
    dat %>% arrange(
      yearmonth,
      partner,
      province,
      regime,
      commodity
    )
}
