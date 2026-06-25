# Concordance table of province names and codes.

A dataset containing the names and codes of China's provinces as well as
regular expressions to match province names in English, German and
Chinese.

## Usage

``` r
province_dict
```

## Format

A data frame with 34 rows and 12 variables:

- iso_3166_2:

  province code according to ISO 3166-2:CN

- gb_2260:

  province code according to Guobiao GB/T 2260

- short_name_en, short_name_zh, short_name_py:

  province name in English, Chinese and Pinyin

- full_name_en, full_name_zh, full_name_py:

  province name including the administrative type, in English, Chinese
  and Pinyin

- regex:

  regular expressions matching province names in English, German and
  Chinese

- type:

  administrative type, e.g., municipality

- mainland:

  Does the province belong to Mainland China? `FALSE` for Hong Kong,
  Macao and Taiwan, `TRUE` otherwise

- china_customs:

  numeric code used by the General Administration of Customs of China

## Source

<https://en.wikipedia.org/wiki/Provinces_of_China>

## Details

The `short_name_*` columns give the bare province name (e.g. Chongqing)
and the `full_name_*` columns include the administrative type (e.g.
Chongqing Shi); the `_en`, `_zh` and `_py` suffixes denote English,
Chinese and Pinyin.
