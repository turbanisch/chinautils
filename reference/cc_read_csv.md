# Read and Clean Trade Data From China Customs

Reads one or more CSV files downloaded from China Customs
(<http://stats.customs.gov.cn/indexEn>) with the correct encoding and
column types, regardless of which columns are present, their order, or
the language (English, Chinese, or a mix across files). Column names are
harmonized to stable English snake_case names and the `yearmonth`
column, if present, is converted to a date.

## Usage

``` r
cc_read_csv(paths, drop_descriptions = TRUE, encoding = "GB18030")
```

## Arguments

- paths:

  Path to one or more CSV files downloaded from China Customs. Files can
  be in English, Chinese, or a mix of both.

- drop_descriptions:

  Keep only codes for commodity, partner country, province, and customs
  regime? Default is `TRUE` because the bundled descriptions are
  redundant and often contain spelling mistakes. Clean descriptions can
  be re-attached from
  [cc_commodities](https://turbanisch.github.io/chinautils/reference/cc_commodities.md),
  [cc_partners](https://turbanisch.github.io/chinautils/reference/cc_partners.md)
  and
  [cc_regimes](https://turbanisch.github.io/chinautils/reference/cc_regimes.md).

- encoding:

  Character encoding of the files. Defaults to `"GB18030"`, the encoding
  China Customs uses (a superset of GBK and GB2312). Override only if
  you re-saved a file in another encoding such as `"UTF-8"`.

## Value

A tibble.

## Details

China Customs exports vary in shape depending on the query: single-month
downloads omit the date column, and the set and order of columns depend
on which dimensions were selected and the chosen sort order. This
function reads each file according to its own header, so files of
different shapes and languages can be read in one call and row-bound
together.

The function emits warnings (rather than failing silently) for three
common problems:

- **Truncation.** The download page silently truncates results at 10,000
  rows. A file with exactly 10,000 data rows may be incomplete.

- **Wrong encoding.** If none of the column names match known China
  Customs variables, the file was probably saved in a different encoding
  than `encoding`.

- **Unrecognized columns.** Columns not found in
  [cc_variable_names](https://turbanisch.github.io/chinautils/reference/cc_variable_names.md)
  are kept under their original name and read as text.

Each line is expected to carry a trailing comma (as added by China
Customs); the resulting empty column is ignored.

## Examples

``` r
# read a single bundled example file
path <- system.file("extdata", "english-full.csv", package = "chinautils")
if (nzchar(path)) cc_read_csv(path)
#> # A tibble: 5 × 10
#>   yearmonth  commodity partner regime province quantity_1 unit_1   quantity_2
#>   <date>     <chr>     <chr>   <chr>  <chr>         <dbl> <chr>         <dbl>
#> 1 2026-01-01 29012920  110     10     44            81782 Kilogram          0
#> 2 2026-01-01 29012920  121     10     44             5800 Kilogram          0
#> 3 2026-01-01 29012920  133     10     31             3574 Kilogram          0
#> 4 2026-01-01 29012920  143     15     61             1248 Kilogram          0
#> 5 2026-01-01 29012920  412     10     37             1725 Kilogram          0
#> # ℹ 2 more variables: unit_2 <chr>, value_usd <dbl>
```
