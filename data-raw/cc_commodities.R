# include only 8-digit HS codes because other ones are standardized
# CSV files of 6-digit codes are corrupted (nested quotation marks)
# it is unclear which HS version China Customs uses in a given year
# small-n investigation indicates that current HS revision is used in each year, e.g., HS6 (2022 revision) starting in 2022

library(tidyverse)

# list files
paths_en <- fs::dir_ls("data-raw/china-customs-codes/commodities/",
                       regexp = "en-hs\\d+-\\d{4}.csv")

paths_zh <- fs::dir_ls("data-raw/china-customs-codes/commodities/",
                       regexp = "zh-hs\\d+-\\d{4}.csv")

# load and bind files
en <- read_csv(paths_en,
               locale = locale(encoding = "GB18030"),
               na = c("?", ""),
               col_select = 1:3,
               col_types = "cci")

zh <- read_csv(paths_zh,
               locale = locale(encoding = "GB18030"),
               na = c("?", ""),
               col_select = 1:3,
               col_types = "cci")

cc_commodities <- en %>% left_join(zh, by = c(CODES = "商品编码", YEAR = "年份"))

# rename and reorder
cc_commodities <- cc_commodities %>%
  rename(
    code = CODES,
    year = YEAR,
    en = DESCRIPTION,
    zh = 商品名称
    ) %>%
  relocate(code, year)


# convert comma into Chinese comma
cc_commodities <- cc_commodities %>% mutate(zh = str_replace_all(zh, ", ?", "，"))

# save
usethis::use_data(cc_commodities, overwrite = TRUE)
