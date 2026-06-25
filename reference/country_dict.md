# Concordance table of country names and codes.

A dataset containing country names in Chinese and regular expressions to
match them. Each set of names in Chinese includes short and full country
names in simplified and traditional scripts as used in Mainland China,
Malaysia, Singapore, Hong Kong, Macau and Taiwan. The dataset
additionally includes English (short) country names and ISO3 codes for
harmonization purposes.

## Usage

``` r
country_dict
```

## Format

A data frame with 208 rows and 15 variables:

- short_name_en:

  Short country name in English

- iso3c:

  ISO3 character country code

- regex:

  regular expressions to match short and full country names (as well as
  variants thereof) after conversion to simplified characters

- short_name_zh_cn, short_name_zh_hk, short_name_zh_mo,
  short_name_zh_my, short_name_zh_sg, short_name_zh_tw:

  Short country name in Chinese, by region

- full_name_zh_cn, full_name_zh_hk, full_name_zh_mo, full_name_zh_my,
  full_name_zh_sg, full_name_zh_tw:

  Full (official) country name in Chinese, by region

## Source

<https://github.com/turbanisch/chinese-countryname-regex>
[https://zh.wikipedia.org/wiki/世界政區索引](https://zh.wikipedia.org/wiki/%E4%B8%96%E7%95%8C%E6%94%BF%E5%8D%80%E7%B4%A2%E5%BC%95)

## Details

|      |                       |                         |
|------|-----------------------|-------------------------|
| Code | Description (Chinese) | Description (English)   |
| cn   | 大陆简体              | Mainland (simplified)   |
| hk   | 香港繁體              | Hong Kong (traditional) |
| mo   | 澳門繁體              | Macau (traditional)     |
| my   | 大马简体              | Malaysia (simplified)   |
| sg   | 新加坡简体            | Singapore (simplified)  |
| tw   | 臺灣正體              | Taiwan (traditional)    |

The Chinese name columns carry a region suffix (`_cn`, `_hk`, `_mo`,
`_my`, `_sg`, `_tw`) as described in the table above.
