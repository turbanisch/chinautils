# China Customs variable names

A dataset containing all variable names that can appear in data
downloaded from Chinese Customs. Variable names are given in English and
Chinese to allow harmonizing them. Not all variables will occur in a
given query.

## Usage

``` r
cc_variable_names
```

## Format

A data frame with 17 rows and 4 variables:

- clean_name:

  name used for harmonization of variable names

- en:

  English variable name

- zh:

  Chinese variable name

- col_type:

  single character denoting the column type, used to generate a column
  type specification for parsing data

## Source

<http://stats.customs.gov.cn/indexEn>

## Details

Some clean names map from more than one English spelling because China
Customs has changed the wording over time (e.g. "Supplimentary" vs
"Supplementary"), so the table has more rows than there are clean names.
