
<!-- README.md is generated from README.Rmd. Please edit that file -->

# chinautils

<!-- badges: start -->
<!-- badges: end -->

This package contains helper functions to make working with Chinese
(administrative) data easier.

## Installation

You can install the development version of chinautils from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("turbanisch/chinautils")
```

## Harmonize province codes

The names of Chinese provinces may vary between institutions and data
sources: Inner Mongolia might come as “Inner Mongol”, “Inner Mongolia
Autonomous Region”, “内蒙古”, “内蒙古自治区”, “Nei Menggu” or “Nei
Menggu Zizhiqu”, making it hard to merge province-level data.

`provincename` uses regular expressions to convert province names in
English, German or Chinese to ISO codes and other output formats, such
as those used by China Customs. It does not, however, take care of
spelling errors that are common in Chinese administrative data. Usually
the name in Chinese characters is the least error-prone.

``` r
library(chinautils)

provincename("Innere Mongolei")
#> [1] "CN-NM"
provincename("Hong Kong", destination = "full_name_zh")
#> [1] "香港特别行政区"
provincename("黑龙江", destination = "china_customs")
#> [1] "23"
```
