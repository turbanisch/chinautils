library(tidyverse)

# files encoded as UTF-8 due to manual editing
en <- read_csv("data-raw/china-customs-codes/partners/en-TradingPartner-cleaned-manually.csv",
               col_select = 1:2, # omit column with comments
               col_types = "cc")

zh <- read_csv("data-raw/china-customs-codes/partners/zh-TradingPartner-cleaned-manually.csv",
               col_types = "cc")

cc_partners <- en %>% left_join(zh)

usethis::use_data(cc_partners)
