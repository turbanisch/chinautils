#' Harmonize (Chinese) Country Names
#'
#' @param sourcevar
#' @param origin
#' @param destination
#'
#' @return
#' @export
#' @import dplyr
#'
#' @examples
countryname <- function(sourcevar, origin = "regex", destination = "iso3c") {
  stopifnot(is.character(sourcevar))
  stopifnot(origin %in% colnames(chinautils::country_dict))
  stopifnot(destination %in% colnames(chinautils::country_dict))


  if (origin == "regex") {
    # simplify Chinese + fuzzy matching
    sourcevar <- ropencc::converter(T2S)[sourcevar]
    join_fun <- fuzzyjoin::regex_left_join
  } else {
    # use exact matching
    join_fun <- dplyr::left_join
  }

  # merge matching entries from dict
  matches <- sourcevar %>%
    as_tibble() %>%
    join_fun(chinautils::country_dict, by = c("value" = origin))

  matches %>% pull(all_of(destination))
}
