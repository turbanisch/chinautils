# China Customs commodity codes

A dataset containing all commodity descriptions used by China Customs in
English and Chinese, including their codes.

## Usage

``` r
cc_commodities
```

## Format

A data frame with 104,236 rows and 4 variables:

- code:

  commodity code

- year:

  year

- en:

  English commodity description

- zh:

  Chinese commodity description

## Source

<http://stats.customs.gov.cn/indexEn>

## Details

This dataset only contains codes at 8-digit level because codes at 2, 4,
and 6-digit level are standardized internationally. Use
`concordance::get_desc()` to retrieve descriptions for those. China
Customs further subdivides the 8-digit codes reported in this dataset
into 10-digit codes.

Note that the usage of codes varies by year. China Customs does not
indicate which HS revision its statistics are based on but a small-n
investigation suggests that the latest version is used for each record.

Data vintage: the dataset covers the years 2015 to 2026. The codes for
2015–2023 were retrieved in April 2024 and those for 2024–2026 in June
2026.
