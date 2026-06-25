# Reading China Customs trade data

``` r

library(chinautils)
library(dplyr)
```

The [China Customs statistics
portal](http://stats.customs.gov.cn/indexEn) lets you download trade
data as CSV files. These files are awkward to read programmatically:

- they are encoded as **GB18030**, not UTF-8;
- column names come in **English or Chinese** depending on the interface
  language, and you may end up with a mix if you download several
  queries;
- the **set and order of columns depends on the query** – a single-month
  download has no date column, and the sort order changes the column
  order.

[`cc_read_csv()`](https://turbanisch.github.io/chinautils/reference/cc_read_csv.md)
hides all of this. It reads one or more files into a single tidy tibble
with stable English column names.

## A single file

This package ships a few small example downloads. A “full” English query
contains the date, the trade dimensions (commodity, partner, customs
regime, province) and the value and quantity columns:

``` r

path <- system.file("extdata", "english-full.csv", package = "chinautils")
cc_read_csv(path)
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

Codes are kept as character vectors (so leading zeros survive), the date
is parsed, and the value column is numeric.

## Many files at once, in any language

Pass a vector of paths to read and row-bind several files – even if they
are in different languages and have different columns. Here we combine
an English file (with a month column) and a Chinese file (a multi-month
aggregate, hence no month column):

``` r

files <- system.file(
  "extdata",
  c("english-full.csv", "chinese-full.csv"),
  package = "chinautils"
)
cc_read_csv(files)
#> Warning: The files do not all contain the same columns.
#> ℹ Missing from at least one file and filled with "NA": "yearmonth",
#>   "value_usd", and "value_cny".
#> ℹ A missing yearmonth is expected when a single-month download (which has no
#>   date column) is combined with other files. Set it manually if you know the
#>   month.
#> # A tibble: 10 × 11
#>    yearmonth  commodity partner regime province quantity_1 unit_1   quantity_2
#>    <date>     <chr>     <chr>   <chr>  <chr>         <dbl> <chr>         <dbl>
#>  1 2026-01-01 29012920  110     10     44            81782 Kilogram          0
#>  2 2026-01-01 29012920  121     10     44             5800 Kilogram          0
#>  3 2026-01-01 29012920  133     10     31             3574 Kilogram          0
#>  4 2026-01-01 29012920  143     15     61             1248 Kilogram          0
#>  5 2026-01-01 29012920  412     10     37             1725 Kilogram          0
#>  6 NA         29012920  110     10     44           214847 千克              0
#>  7 NA         29012920  121     10     44            12577 千克              0
#>  8 NA         29012920  133     10     21              100 千克              0
#>  9 NA         29012920  133     10     31             6750 千克              0
#> 10 NA         29012920  133     10     37               48 千克              0
#> # ℹ 3 more variables: unit_2 <chr>, value_usd <dbl>, value_cny <dbl>
```

The Chinese rows have a missing `yearmonth` and populate `value_cny`
instead of `value_usd`: values reported in different currencies are
deliberately kept in separate columns so they are never accidentally
summed.

## Single-month downloads

If you download a single month, China Customs omits the date column
entirely.
[`cc_read_csv()`](https://turbanisch.github.io/chinautils/reference/cc_read_csv.md)
handles this without complaint – it simply returns a table without
`yearmonth`:

``` r

degen <- system.file("extdata", "english-degenerate.csv", package = "chinautils")
cc_read_csv(degen)
#> # A tibble: 3 × 6
#>   commodity quantity_1 unit_1   quantity_2 unit_2 value_usd
#>   <chr>          <dbl> <chr>         <dbl> <chr>      <dbl>
#> 1 29012920        4333 Kilogram          0 NA        419601
#> 2 29012990    14198093 Kilogram          0 NA      17715334
#> 3 29021100         383 Kilogram          0 NA         10451
```

## Re-attaching clean descriptions

By default
[`cc_read_csv()`](https://turbanisch.github.io/chinautils/reference/cc_read_csv.md)
drops the descriptions that ship alongside each code, because they are
redundant and frequently misspelled. Re-attach clean descriptions from
the bundled lookup tables when you need them:

``` r

trade <- cc_read_csv(path)

trade |>
  left_join(cc_partners, by = c("partner" = "code")) |>
  select(partner, partner_en = en, value_usd)
#> # A tibble: 5 × 3
#>   partner partner_en  value_usd
#>   <chr>   <chr>           <dbl>
#> 1 110     Hong Kong      315286
#> 2 121     Macau           28579
#> 3 133     South Korea    199307
#> 4 143     Taiwan         234351
#> 5 412     Chile            4137
```

Commodity descriptions are versioned by year, so join `cc_commodities`
on both the commodity code and the year:

``` r

trade |>
  mutate(year = lubridate::year(yearmonth)) |>
  left_join(cc_commodities, by = c("commodity" = "code", "year")) |>
  distinct(commodity, year, en)
#> # A tibble: 1 × 3
#>   commodity  year en       
#>   <chr>     <dbl> <chr>    
#> 1 29012920   2026 Acetylene
```

## Things to watch out for

[`cc_read_csv()`](https://turbanisch.github.io/chinautils/reference/cc_read_csv.md)
warns about several silent pitfalls of the download page:

- **Truncation.** The portal caps a download at 10,000 rows. If a file
  has exactly 10,000 data rows it may be incomplete, and you get a
  warning.
- **Encoding.** If the column names cannot be decoded as GB18030 (for
  example because a file was re-saved as UTF-8),
  [`cc_read_csv()`](https://turbanisch.github.io/chinautils/reference/cc_read_csv.md)
  stops with a clear message; pass `encoding = "UTF-8"` to override the
  default.
- **Mismatched columns.** When you read several files at once and they
  do not all share the same columns, you get a warning, because the
  affected rows are filled with `NA`. This is the case described above
  when you append a single-month update to a dated series.

One pitfall cannot be detected automatically: the **trade flow**.
Imports, exports and combined “import and export” downloads all have
exactly the same columns – the direction is never stored in the file. If
you read an imports-only file together with an exports-only file, the
two are merged without warning. Tag each file yourself before binding if
you need to keep them apart:

``` r

imports <- cc_read_csv("imports.csv") |> mutate(flow = "import")
exports <- cc_read_csv("exports.csv") |> mutate(flow = "export")
bind_rows(imports, exports)
```
