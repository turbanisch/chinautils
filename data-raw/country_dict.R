# import regular expressions for country names in Chinese and save

library(readr)

# read URL to raw CSV file on GitHub
country_dict <- read_csv("https://raw.githubusercontent.com/turbanisch/chinese-countryname-regex/main/data/dict.csv",
                         col_types = cols(.default = col_character()))

# save
usethis::use_data(country_dict, overwrite = TRUE)
