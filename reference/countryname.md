# Harmonize Country Names in Chinese

This function identifies country names in Chinese and converts them to
various standardized output formats, such as ISO3 codes. It uses regular
expressions to match country name variants in both simplified and
traditional Chinese.

## Usage

``` r
countryname(sourcevar, origin = "regex", destination = "iso3c")
```

## Source

Methodology and code for the conversion table can be found in [this
repo](https://github.com/turbanisch/chinese-countryname-regex).

## Arguments

- sourcevar:

  Vector which contains the codes or country names to be converted
  (character or factor)

- origin:

  A string which identifies the coding scheme of origin (e.g.,
  `"short_name_zh_cn"`). See
  [`chinautils::country_dict`](https://turbanisch.github.io/chinautils/reference/country_dict.md)
  for a list of available codes. If not specified, the country name in
  Chinese (simplified or traditional) will be matched via regular
  expressions. Otherwise the match needs to be an exact match (i.e., not
  just a partial one).

- destination:

  A string which identify the coding scheme of destination (e.g.,
  `"short_name_en"`). See
  [`chinautils::country_dict`](https://turbanisch.github.io/chinautils/reference/country_dict.md)
  for a list of available codes. If not specified, ISO3 codes will be
  used.

## Value

A character vector

## Note

In the case of regex matching, the input is first converted from
traditional to simplified characters using ICU text transforms (via the
`stringi` package), so that traditional-character input matches the
simplified-character dictionary.

The message informing about the number of successful conversions refers
to unique values of the input vector. Character variants (think:
simplified vs. traditional) are counted as two distinct values. A
resulting missing value is due to one of two reasons: either there was
no match or there were multiple matches and thus the result was
ambiguous. Additional info messages inform the user about each cause.

## Examples

``` r
# match variants in both simplified and traditional Chinese
countryname(c("中国", "中华人民共和国", "亞東開化中國早"))
#> ✔ Matched 3 out of 3 values.
#> [1] "CHN" "CHN" "CHN"

# regex ignore languages other than Chinese and ambiguous cases
countryname(c("ドイツ国", "刚果"))
#> ✖ Failed to match 2 out of 2 values.
#> ℹ No match could be found for ドイツ国 and 刚果.
#> [1] NA NA

# get warned about potential pitfalls, such as multiple matches
countryname(c("塞尔维亚和黑山", "捷克斯洛伐克", "德国德国"))
#> ✖ Failed to match 2 out of 3 values.
#> ℹ Multiple matches were found for 塞尔维亚和黑山 and 捷克斯洛伐克.
#> [1] NA    NA    "DEU"

# non-regex matching requires an exact match
countryname(c("德国", "德国人"), origin = "short_name_zh_cn", destination = "short_name_en")
#> ✖ Failed to match 1 out of 2 values.
#> ℹ No match could be found for 德国人.
#> [1] "Germany" NA       
```
