#' Read and Clean Trade Data From China Customs
#'
#' This is a function to read CSV files downloaded from China Customs with the correct encoding and column type specification. It expects data that was queried by month across the four dimensions commodity, partner country, province, and customs regime. The function harmonizes column names between English and Chinese files, converts dates and adds an ISO3 identifier for Chinese provinces.
#'
#' Note that this function does not perform any sanity checks on the data, so make sure no individual CSV file was cut off after 10,000 lines.
#'
#' @param file Path to one or multiple CSV files downloaded from China Customs. Files can be in English, Chinese, or a mix of both.
#' @param drop_descriptions Keep only codes for commodity, partner country, province, and customs regime? Default is `TRUE` because descriptions are redundant and often include spelling mistakes.
#'
#' @return A tibble
#' @export
#' @import dplyr
cc_read_csv <- function(file, drop_descriptions = TRUE) {
  # read data
  dat <- readr::read_csv(
      file = file,
      na = "?",
      locale = readr::locale(encoding = "GB18030"),
      col_types = "cccccccccdcdcn_", # trailing comma is interpreted as extra column, do not read in
      col_names = chinautils::cc_variable_names$clean_name,
      skip = 1L # skip column names present in the data
    )

  # drop redundant descriptions
  if (drop_descriptions) dat <- dat %>% select(!ends_with("_name"))

  # convert yearmonth to date
  dat <- dat %>% mutate(yearmonth = lubridate::ym(yearmonth))

  # convert province code to ISO
  dat <- dat %>% mutate(province_code = chinautils::provincename(province_code, origin = "china_customs"))

  # sort
  dat %>% arrange(yearmonth, partner_code, province_code, regime_code, commodity_code)
}
