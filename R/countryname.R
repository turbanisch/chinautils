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
