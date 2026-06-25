# Harmonize Province Names

This is a thin wrapper around
[`countrycode::countrycode()`](https://vincentarelbundock.github.io/countrycode/man/countrycode.html)
using a custom dictionary for Chinese provinces. By default, the
province name is matched by regular expressions and converted into ISO
codes.

## Usage

``` r
provincename(sourcevar, origin = "regex", destination = "iso_3166_2", ...)
```

## Arguments

- sourcevar:

  Vector which contains the codes or province names to be converted
  (character or factor)

- origin:

  A string which identifies the coding scheme of origin (e.g.,
  `"china_customs"`). See
  [`chinautils::province_dict`](https://turbanisch.github.io/chinautils/reference/province_dict.md)
  for a list of available codes. If not specified, the province name in
  English, German or Chinese will be matched via regular expressions.
  Otherwise the match needs to be an exact match (i.e., not just a
  partial one).

- destination:

  A string or vector of strings which identify the coding scheme of
  destination (e.g., `"type"` or `c("gb_2260", "full_name_zh")`). If not
  specified, ISO codes will be used. See
  [`chinautils::province_dict`](https://turbanisch.github.io/chinautils/reference/province_dict.md)
  for a list of available codes. When users supply a vector of
  destination codes, they are used sequentially to fill in missing
  values not covered by the previous destination code in the vector.

- ...:

  Additional parameters passed on to
  [`countrycode::countrycode()`](https://vincentarelbundock.github.io/countrycode/man/countrycode.html)

## Value

A character vector

## Note

The list of provinces is based on [ISO
3166-2:CN](https://en.wikipedia.org/wiki/ISO_3166-2:CN) which includes
Taiwan.

## Examples

``` r
provincename("Innere Mongolei")
#> [1] "CN-NM"
provincename("Hong Kong", destination = "full_name_zh")
#> [1] "香港特别行政区"
provincename("Formosa", destination = "type")
#> [1] "claimed province"
```
