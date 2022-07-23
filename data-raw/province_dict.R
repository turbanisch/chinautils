library(tidyverse)
library(rvest)

# ISO codes ---------------------------------------------------------------

# scrape from Wikipedia permalink
url <- "https://en.wikipedia.org/w/index.php?title=ISO_3166-2:CN&oldid=1081005445"
html <- read_html(url)

iso <- html %>%
  html_element(xpath = "/html/body/div[3]/div[3]/div[5]/div[1]/table[1]") %>%
  html_table() %>%
  # remove second column (is neither Pinyin nor English)
  select(!2)

colnames(iso) <- c("iso_3166_2", "name", "type")

# adjust status of Taiwan
iso <- iso %>%
  mutate(type = if_else(iso_3166_2 == "CN-TW", "claimed province", type))

# extract 2-digit code
# ("The second part is a two-letter alphabetic code specified by Guobiao GB/T 2260")
iso <- iso %>%
  mutate(gb_2260 = str_extract(iso_3166_2, "..$"),
         .after = iso_3166_2)

# extract Chinese and Pinyin names
remove_tonemarks <- function(string) {
  stringi::stri_trans_general(string, id = "Latin-ASCII")
}

iso <- iso %>%
  mutate(
    full_name_zh = str_extract(name, "\\p{script=Han}+"),
    full_name_py = remove_tonemarks(str_match(name, "\\((.*)\\)")[,2])
  ) %>%
  select(!name) %>%
  # recover Shaanxi
  mutate(full_name_py = if_else(iso_3166_2 == "CN-SN", "Shaanxi Sheng", full_name_py))

# extract short name (first word of full name)
iso <- iso %>%
  mutate(short_name_py = str_extract(full_name_py, "\\S*")) %>%
  # correct Nei Menggu
  mutate(short_name_py = if_else(iso_3166_2 == "CN-NM", "Nei Menggu", short_name_py))

# derive latin regexes
iso <- iso %>%
  mutate(regex = str_to_lower(short_name_py))

# replace special cases manually (should match both English, German, and Pinyin)
update <- tribble(
  ~iso_3166_2, ~regex,
  "CN-BJ", "beijing|peking",
  "CN-GD", "guangdong|kanton|canton",
  "CN-HK", "xianggang|hong ?kong",
  "CN-MO", "aomen|macao|macau",
  "CN-NM", "nei menggu|mongol",
  "CN-SH", "sc?hanghai",
  "CN-TW", "taiwan|formosa",
  "CN-XZ", "xizang|tibet*"
)

iso <- iso %>%
  rows_update(update, by = "iso_3166_2")

# derive Chinese short name (first two characters of full name)
iso <- iso %>%
  mutate(short_name_zh = str_extract(full_name_zh, "^.."))

# recover Chinese names with more than 2 characters
update_zh <- tribble(
  ~iso_3166_2, ~short_name_zh,
  "CN-HL", "黑龙江",
  "CN-NM", "内蒙古"
)

iso <- iso %>%
  rows_update(update_zh, by = "iso_3166_2")

# combine (latin) regex with Chinese short name and add catch-all
iso <- iso %>%
  mutate(regex = str_c(".*", regex, "|", short_name_zh, ".*"))


# get English names -------------------------------------------------------

# scrape from Wikipedia permalink
url <- "https://en.wikipedia.org/w/index.php?title=Provinces_of_China&oldid=1099108026"
html <- read_html(url)

english <- html %>%
  html_element(xpath = "/html/body/div[3]/div[3]/div[5]/div[1]/table[5]") %>%
  html_table() %>%
  select(2:3)

colnames(english) <- c("iso_3166_2", "full_name_en")

# remove footnotes
english <- english %>%
  mutate(across(
    .fns = ~str_remove(.x, "\\[.*\\]")
  ))

# derive English short name (first word of full name)
english <- english %>%
  mutate(short_name_en = str_extract(full_name_en, "\\S+"))

update <- tribble(
  ~iso_3166_2, ~short_name_en,
  "CN-HK", "Hong Kong",
  "CN-NM", "Inner Mongolia"
)

english <- english %>%
  rows_update(update, by = "iso_3166_2")


# china customs -----------------------------------------------------------

# load Chinese province names
province_codes_zh <- read_csv(
  "data-raw/收发货人注册地参数导出.csv",
  locale = locale(encoding = "GB18030"),
  col_select = c("收发货人注册地编码", "收发货人注册地名称"),
  col_types = cols(.default = col_character())
) %>%
  rename(
    china_customs = 收发货人注册地编码,
    customs_province_name_zh = 收发货人注册地名称
  )


# merge -------------------------------------------------------------------

province_dict <- iso %>%
  left_join(english, by = "iso_3166_2") %>%
  left_join(province_codes_zh, by = c("full_name_zh" = "customs_province_name_zh"))

# reorder variables
province_dict <- province_dict %>%
  relocate(
    iso_3166_2,
    gb_2260,
    short_name_en,
    short_name_zh,
    short_name_py,
    full_name_en,
    full_name_zh,
    full_name_py,
    regex
  )

# Identify regular expression origin codes (for countrycode)
attr(province_dict, "origin_regex") <- "regex"

# save --------------------------------------------------------------------

usethis::use_data(province_dict, overwrite = TRUE)
