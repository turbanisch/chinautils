#' Read and Clean Trade Data From China Customs
#'
#' @param file
#' @param drop_descriptions
#'
#' @return
#' @export
#' @import dplyr
#'
#' @examples
cc_read_csv <- function(file, drop_descriptions = TRUE) {
  # read data
  dat <- readr::read_csv(
      file = file,
      na = "?",
      locale = readr::locale(encoding = "GB18030"),
      col_types = "cccccccccdcdcn_", # trailing comma is interpreted as extra column, do not read in
      col_names = chinautils::cc_variable_names$clean_name,
      skip = 1L # skip colnames present in the data
    )

  if (drop_descriptions) dat <- dat %>% select(!ends_with("_name"))

  # convert yearmonth to date
  dat <- dat %>% mutate(yearmonth = lubridate::ym(yearmonth))

  # convert province code to ISO
  dat <- dat %>% mutate(province_code = chinautils::provincename(province_code, origin = "china_customs"))

  # sort
  dat %>% arrange(yearmonth, partner_code, province_code, regime_code, commodity_code)

}
