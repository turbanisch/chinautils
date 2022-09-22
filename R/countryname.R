#' Harmonize Country Names
#'
#' @param sourcevar Vector which contains the codes or country names to be
#'   converted (character or factor)
#' @param origin A string which identifies the coding scheme of origin (e.g.,
#'   `"short_name_zh_cn"`). See `chinautils::country_dict` for a list of available codes. If not specified, the country name in Chinese (simplified or traditional) will be matched via regular expressions. Otherwise the match needs to be an exact match (i.e., not just a partial one).
#' @param destination A string which identify the coding
#'   scheme of destination (e.g., `"short_name_en"`). See `chinautils::country_dict` for a list of available codes.
#'   If not specified, ISO3 codes will be used.
#'
#' @return A character vector
#' @export
#' @import dplyr
#'
#' @examples
#' # match both simplified and traditional Chinese
#' countryname(c("德国", "德國"))
#'
#' # regex ignore languages other than Chinese and ambiguous cases
#' countryname(c("ドイツ国", "刚果"))
#'
#' # get warned about potential pitfalls, such as multiple matches
#' countryname(c("塞尔维亚和黑山", "捷克斯洛伐克", "德国德国"))
#'
#' # non-regex matching requires an exact match
#' countryname(c("德国", "德国人"), origin = "short_name_zh_cn", destination = "short_name_en")
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

  # check no match
  no_match <- matches %>% filter(is.na(short_name_en)) %>% pull(value)

  # identify multiple matches
  dupes <- matches %>%
    count(value) %>%
    filter(n > 1) %>%
    pull(value)

  # remove duplicates and set NA in case of multiple matches
  matches <- matches %>%
    mutate(across(!value, ~if_else(value %in% dupes, NA_character_, .x))) %>%
    distinct()

  # inform user about missings and duplicates
  if (length(no_match) == length(sourcevar)) {
    cli::cli_inform(c("x" = "Matched {length(sourcevar) - length(no_match)} out of {length(sourcevar)} value{?s}."))
  } else{
    cli::cli_inform(c("v" = "Matched {length(sourcevar) - length(no_match)} out of {length(sourcevar)} value{?s}."))

    if (length(no_match) > 0) cli::cli_inform(c("x" = "Could not match {no_match}."))

    if (length(dupes) > 0) {
      cli::cli_inform(c(
        "x" = "Found multiple matches for {dupes}.",
        "i" = "Values with multiple matches were converted to NA."))
    } else {
      cli::cli_inform(c("v" = "No value had multiple matches."))
    }
  }

  # return
  matches %>% pull(all_of(destination))
}
