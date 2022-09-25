
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

## Harmonize country names (in Chinese)

Coming up with regular expressions to match country names in Chinese is
slightly more involved than for other languages. The reason is that
different parts of the world use different variants of Chinese, beyond
the basic distinction between simplified and traditional characters.
Mainland China, Malaysia and Singapore all use simplified characters
whereas Hong Kong, Macau and Taiwan continue to use traditional
characters – but local usage may vary within each group.

This is especially true for proper names like country names. Not only
can they vary character by character depending on the script that is
used, but they might also reflect different (phonetic) transliterations
or refer to another name altogether. Here are some examples for each
case:

1.  **Different scripts.** Germany is referred to as *Deguo* 德国 in
    Mainland China and 德國 in Taiwan – where 国 is the simplified
    character corresponding to 國, easy. However, there are some less
    obvious cases, as we will see below.
2.  **Different transliterations**. Many country names have been
    phonetically adapted from other languages and translators in every
    Chinese-speaking region have taken their artistic liberties when
    doing so. For example, Hong Kongers refer to Barbados as *Babaduosi*
    巴巴多斯 whereas people from Taiwan call it *Babeiduo* 巴貝多.
3.  **Alternative names**. Instead of adapting a country name according
    to its sound, Chinese-speaking people in some regions have also
    opted to convert the original meaning of the country name into
    Chinese. For example, Montenegro is *Heishan* 黑山 (“black
    mountain”) in Mainland China. People on Taiwan, on the other hand,
    kept their phonetic transliteration *Mengteneigeluo* 蒙特內哥羅.

The function `countryname` identifies country names in Chinese and
converts them to various standardized output formats, such as ISO3
codes. It uses regular expressions to match country name variants in
both simplified and traditional Chinese:

``` r
# match variants in both simplified and traditional Chinese
countryname(c("中国", "中华人民共和国", "亞東開化中國早"))
#> ✔ Matched 3 out of 3 unique values unambiguously.
#> [1] "CHN" "CHN" "CHN"

# regex ignore languages other than Chinese and ambiguous cases
countryname(c("ドイツ国", "刚果"))
#> ✖ Failed to match 2 out of 2 unique values unambiguously.
#> ℹ No match could be found for ドイツ国 and 刚果.
#> [1] NA NA

# get warned about potential pitfalls, such as multiple matches
countryname(c("塞尔维亚和黑山", "捷克斯洛伐克", "德国德国"))
#> ✖ Failed to match 2 out of 3 unique values unambiguously.
#> ℹ Multiple matches were found for 塞尔维亚和黑山 and 捷克斯洛伐克.
#> [1] NA    NA    "DEU"

# non-regex matching requires an exact match
countryname(c("德国", "德国人"), origin = "short_name_zh_cn", destination = "short_name_en")
#> ✖ Failed to match 1 out of 2 unique values unambiguously.
#> ℹ No match could be found for 德国人.
#> [1] "Germany" NA
```

## Harmonize province codes

The names of Chinese provinces may vary between data sources: Inner
Mongolia might come as “Inner Mongol”, “Inner Mongolia Autonomous
Region”, “内蒙古”, “内蒙古自治区”, “Nei Menggu” or “Nei Menggu Zizhiqu”,
making it hard to merge province-level data.

`provincename` uses regular expressions to convert province names in
English, German or Chinese to ISO codes and other output formats, such
as those used by China Customs.

``` r
provincename("Innere Mongolei")
#> [1] "CN-NM"
provincename("Hong Kong", destination = "full_name_zh")
#> [1] "香港特别行政区"
provincename("黑龙江", destination = "china_customs")
#> [1] "23"
```

The function does not, however, take care of spelling errors that are
pervasive in Chinese administrative data. Usually, the name in Chinese
characters is the least error-prone. When regular expressions fail to
capture province names, fuzzy matching using string distance based on
the custom dictionary `chinautils::province_dict` will likely get the
job done:

``` r
library(tidyverse)

# create (misspelled) province names to be matched
df <- tibble(
  misspelled = c("Schanghai",
                 "Peking",
                 "Innere Mongolei", 
                 "Hong Kong", 
                 "Hong Kong Special Administrative Zone",
                 "Xingjiang")
)

# filter cartesian join by shortest distance
df %>% 
  left_join(select(province_dict, short_name_en),
            by = character(0)) %>% 
  mutate(dist = stringdist::stringdist(misspelled, short_name_en)) %>% 
  group_by(misspelled) %>% 
  filter(min_rank(dist) == 1L) %>% 
  ungroup()
#> # A tibble: 6 × 3
#>   misspelled                            short_name_en   dist
#>   <chr>                                 <chr>          <dbl>
#> 1 Schanghai                             Shanghai           1
#> 2 Peking                                Beijing            3
#> 3 Innere Mongolei                       Inner Mongolia     3
#> 4 Hong Kong                             Hong Kong          0
#> 5 Hong Kong Special Administrative Zone Hong Kong         28
#> 6 Xingjiang                             Xinjiang           1
```
