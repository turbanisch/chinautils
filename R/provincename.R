#' Harmonize Province Names
#'
#' This is a thin wrapper around `countrycode::countrycode()` using a custom
#' dictionary for Chinese provinces. By default, the province name is matched by
#' regular expressions and converted into ISO codes.
#'
#' @note The list of provinces is based on [ISO
#'   3166-2:CN](https://en.wikipedia.org/wiki/ISO_3166-2:CN) which includes
#'   Taiwan.
#'
#' @param sourcevar Vector which contains the codes or province names to be
#'   converted (character or factor)
#' @param origin A string which identifies the coding scheme of origin (e.g.,
#'   `"china_customs"`). See `chinautils::province_dict` for a list of available codes.
#'   If not specified, the province name in English, German or Chinese will be matched via regular expressions. Otherwise the match needs to be an exact match (i.e., not just a partial one).
#' @param destination A string or vector of strings which identify the coding
#'   scheme of destination (e.g., `"type"` or `c("gb_2260", "full_name_zh")`).
#'   If not specified, ISO codes will be used. See `chinautils::province_dict`
#'   for a list of available codes. When users supply a vector of destination
#'   codes, they are used sequentially to fill in missing values not covered by
#'   the previous destination code in the vector.
#' @param ... Additional parameters passed on to `countrycode::countrycode()`
#'
#' @return A character vector
#' @export
#'
#' @examples
#' provincename("Innere Mongolei")
#' provincename("Hong Kong", destination = "full_name_zh")
#' provincename("Formosa", destination = "type")
provincename <- function(sourcevar,
                         origin = "regex",
                         destination = "iso_3166_2",
                         ...) {
  countrycode::countrycode(
    sourcevar,
    origin = origin,
    destination = destination,
    custom_dict = chinautils::province_dict,
    ...
  )
}
