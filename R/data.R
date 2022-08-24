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