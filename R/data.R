#' Concordance table of country names and codes.
#'
#' A dataset containing the names and codes of China's provinces as well as regular expressions to match province names in English, German and Chinese.
#'
#' @format A data frame with 34 rows and 12 variables:
#' \describe{
#'   \item{iso_3166_2}{province code according to ISO 3166-2:CN}
#'   \item{gb_2260}{province code according to Guobiao GB/T 2260}
#'   \item{short_name_}{province name, e.g., Chongqing}
#'   \item{full_name_}{province name including the administrative type, e.g., Chongqing Shi}
#'   \item{_en}{province name in English}
#'   \item{_zh}{province name in Chinese}
#'   \item{_py}{province name in Pinyin (the official romanization system for Chinese in Mainland China)}
#'   \item{regex}{regular expressions matching province names in English, German and Chinese}
#'   \item{type}{administrative type, e.g., municipality}
#'   \item{mainland}{Does the province belong to Mainland China? `FALSE` for Hong Kong, Macao and Taiwan, `TRUE` otherwise}
#'   \item{china_customs}{numeric code used by the General Administration of Customs of China}
#' }
#' @source \url{https://en.wikipedia.org/wiki/Provinces_of_China}
"country_dict"

#' Concordance table of province names and codes.
#'
#' A dataset containing the names and codes of China's provinces as well as regular expressions to match province names in English, German and Chinese.
#'
#' @format A data frame with 34 rows and 12 variables:
#' \describe{
#'   \item{iso_3166_2}{province code according to ISO 3166-2:CN}
#'   \item{gb_2260}{province code according to Guobiao GB/T 2260}
#'   \item{short_name_}{province name, e.g., Chongqing}
#'   \item{full_name_}{province name including the administrative type, e.g., Chongqing Shi}
#'   \item{_en}{province name in English}
#'   \item{_zh}{province name in Chinese}
#'   \item{_py}{province name in Pinyin (the official romanization system for Chinese in Mainland China)}
#'   \item{regex}{regular expressions matching province names in English, German and Chinese}
#'   \item{type}{administrative type, e.g., municipality}
#'   \item{mainland}{Does the province belong to Mainland China? `FALSE` for Hong Kong, Macao and Taiwan, `TRUE` otherwise}
#'   \item{china_customs}{numeric code used by the General Administration of Customs of China}
#' }
#' @source \url{https://en.wikipedia.org/wiki/Provinces_of_China}
"province_dict"

#' China Customs customs regime names
#'
#' A dataset containing all customs regime names used by China Customs in English and Chinese, including their codes.
#'
#' @format A data frame with 20 rows and 3 variables:
#' \describe{
#'   \item{code}{customs regime code}
#'   \item{en}{English customs regime name}
#'   \item{zh}{Chinese customs regime name}
#' }
#' @source \url{43.248.49.97/indexEn}
"cc_regimes"

#' China Customs variable names
#'
#' A dataset containing all variable names that can appear in data downloaded from Chinese Customs. Variable names are given in English and Chinese to allow harmonizing them. Not all variables will occur in a given query.
#'
#' @format A data frame with 15 rows and 4 variables:
#' \describe{
#'   \item{clean_name}{name used for harmonization of variable names}
#'   \item{en}{English variable name}
#'   \item{zh}{Chinese variable name}
#'   \item{col_type}{single character denoting the column type, used to generate a column type specification for parsing data}
#' }
#' @source \url{43.248.49.97/indexEn}
"cc_variable_names"

#' China Customs trading partner names
#'
#' A dataset containing all countries and regions listed as trading partners by China Customs. Note that the entries are not necessarily independent states. For example, Canary Islands are listed separately from Spain. The list also contains legacy states, such as Serbia and Montenegro, and residual categories (e.g., Other Oceania nes  ).
#'
#' @format A data frame with 243 rows and 3 variables:
#' \describe{
#'   \item{code}{trading partner code}
#'   \item{en}{English trading partner name}
#'   \item{zh}{Chinese trading partner name}
#' }
#' @source \url{43.248.49.97/indexEn}
"cc_partners"

#' China Customs commodity descriptions
#'
#' A dataset containing all 8-digit commodity codes and their descriptions in English and Chinese from China Customs, by year. HS codes up to the 6-digit level are standardized and can be queried through the `concordance` package. Note that it is unclear which HS revision China Customs was using in a given year.
#'
#' @format A data frame with 51,769 rows and 4 variables:
#' \describe{
#'   \item{code}{commodity code}
#'   \item{year}{year}
#'   \item{en}{English commodity name}
#'   \item{zh}{Chinese commodity name}
#' }
#' @source \url{43.248.49.97/indexEn}
"cc_partners"
