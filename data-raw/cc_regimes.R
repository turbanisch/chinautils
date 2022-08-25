library(tidyverse)

en <- read_csv("data-raw/china-customs-codes/regimes/en-CustomsRegime.csv",
               locale = locale(encoding = "GB18030"),
               col_select = 1:2,
               col_types = "cc")

zh <- read_csv("data-raw/china-customs-codes/regimes/zh-CustomsRegime.csv",
               locale = locale(encoding = "GB18030"),
               col_select = 1:2,
               col_types = "cc")

en <- en %>%
  rename(
    code = `Customs Regime code`,
    en = `Customs Regime`
  ) %>%
  mutate(en = str_to_lower(en))

zh <- zh %>%
  rename(
    code = 贸易方式编码,
    zh = 贸易方式名称
  )

cc_regimes <- en %>% left_join(zh)

usethis::use_data(cc_regimes)
