# Mapping of China Customs CSV column headers to stable clean names and readr
# column types. Maintained by hand (there is no machine-readable source): China
# Customs has used more than one English spelling over time -- notably
# "Supplimentary" vs "Supplementary" -- so a few clean names map from several
# source headers. Each currency also has its own value column in both languages.

library(tibble)

cc_variable_names <- tribble(
  ~clean_name,      ~en,                                         ~zh,            ~col_type,
  "yearmonth",      "Date of data",                              "数据年月",      "c",
  "commodity",      "Commodity code",                            "商品编码",      "c",
  "commodity_name", "Commodity",                                 "商品名称",      "c",
  "partner",        "Trading partner code",                      "贸易伙伴编码",  "c",
  "partner_name",   "Trading partner",                           "贸易伙伴名称",  "c",
  "regime",         "Customs Regime code",                       "贸易方式编码",  "c",
  "regime_name",    "Customs Regime",                            "贸易方式名称",  "c",
  "province",       "Locations of importers and exporters code", "注册地编码",    "c",
  "province_name",  "Locations of importers and exporters",      "注册地名称",    "c",
  "quantity_1",     "Quantity",                                  "第一数量",      "d",
  "unit_1",         "Unit",                                      "第一计量单位",  "c",
  "quantity_2",     "Supplimentary Quantity",                    "第二数量",      "d",
  "quantity_2",     "Supplementary Quantity",                    "第二数量",      "d",
  "unit_2",         "Supplimentary Unit",                        "第二计量单位",  "c",
  "unit_2",         "Supplementary Unit",                        "第二计量单位",  "c",
  "value_usd",      "US dollar",                                 "美元",          "n",
  "value_cny",      "Renminbi Yuan",                             "人民币",        "n",
)

usethis::use_data(cc_variable_names, overwrite = TRUE)
