#' Harmonize Country Names in Chinese
#'
#' This function identifies country names in Chinese and converts them to various standardized output formats, such as ISO3 codes. It uses regular expressions to match country name variants in both simplified and traditional Chinese.
#'
#' @source Methodology and code for the conversion table can be found in [this repo](https://github.com/turbanisch/chinese-countryname-regex).
#'
#' @note In the case of regex matching, the input is converted to simplified characters using [OpenCC](https://github.com/BYVoid/OpenCC) first.
#'
#' @note The message informing about the number of successful conversions refers to unique values of the input vector. Character variants (think: simplified vs. traditional) are counted as two distinct values. A resulting missing value is due to one of two reasons: either there was no match or there were multiple matches and thus the result was ambiguous. Additional info messages inform the user about each cause.
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
#' # match variants in both simplified and traditional Chinese
#' countryname(c("中国", "中华人民共和国", "亞東開化中國早"))
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
  stopifnot(length(origin) == 1L)
  stopifnot(length(destination) == 1L)

  # keep only relevant columns
  country_dict <- chinautils::country_dict %>% select(all_of(c(origin, destination)))

  # make a copy, apply conversion to the full vector at the very end
  full_sourcevar <- sourcevar

  # reduce to unique values (to help identify 1:m merges later)
  sourcevar <- unique(sourcevar)

  if (origin == "regex") {
    # simplify Chinese + fuzzy matching
    merge_key <- ropencc::converter(ropencc::T2S)[sourcevar]
    join_fun <- fuzzyjoin::regex_left_join
  } else {
    # use exact matching
    join_fun <- dplyr::left_join
    merge_key <- sourcevar
  }

  # keep simplified and original values side-by-side
  conversion_table <- tibble(sourcevar, merge_key)

  # merge matching entries from dict
  matches <- conversion_table %>%
    join_fun(country_dict, by = c(merge_key = origin))

  # check no match (before converting duplicates to NA)
  no_match <- matches %>% filter(if_all(destination, is.na)) %>% pull(sourcevar)

  # identify multiple matches
  dupes <- matches %>%
    count(sourcevar) %>%
    filter(n > 1) %>%
    pull(sourcevar)

  # remove duplicates and set NA in case of multiple matches
  matches <- matches %>%
    mutate(across(any_of(c(origin, destination)), ~if_else(sourcevar %in% dupes, NA_character_, .x))) %>%
    distinct()

  # compute successful matches for messages to user
  n_success <- matches %>% filter(if_all(destination, ~!is.na(.x))) %>% nrow()
  n_failure <- length(sourcevar) - n_success

  # inform user about missings and duplicates
  if (n_failure == 0) {
    cli::cli_alert_success("Matched {n_success} out of {length(sourcevar)} value{?s}.")
  }
  else {
    cli::cli_alert_danger("Failed to match {n_failure} out of {length(sourcevar)} value{?s}.")
    if (length(no_match) > 0)
      cli::cli_alert_info("No match could be found for {no_match}.")
    if (length(dupes) > 0)
      cli::cli_alert_info("Multiple matches were found for {dupes}. ")
  }

  # return matches of full (non-unique) sourcevar from the beginning
  matches %>%
    select(sourcevar, all_of(destination)) %>%
    right_join(tibble(sourcevar = full_sourcevar), by = "sourcevar") %>%
    pull(all_of(destination))
}
