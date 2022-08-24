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

  col_types <- if (drop_descriptions) "cc_c_c_c_dcdcn_" else "cccccccccdcdcn_"

  # read data
  dat <- readr::read_csv(
      file = file,
      na = "?",
      locale = readr::locale(encoding = "GB18030"),
      col_types = col_types
    )

  # harmonize variable names
  concordance <- chinautils::cc_variable_names %>%
    mutate(pattern = stringr::str_c("^", zh, "$", "|", "^", en, "$"))
  dict <- concordance$clean_name %>% rlang::set_names(concordance$pattern)
  dat <- dat %>% rename_with(~stringr::str_replace_all(.x, dict))

  # convert yearmonth to date
  dat <- dat %>% mutate(yearmonth = lubridate::ym(yearmonth))

  # convert province code to ISO
  dat %>% mutate(province_code = chinautils::provincename(province_code, origin = "china_customs"))
}
