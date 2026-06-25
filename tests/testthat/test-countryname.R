test_that("input order is preserved in the presence of duplicates", {
  input <- c("南非", "德国", "南非")
  expect_equal(suppressMessages(countryname(input)), c("ZAF", "DEU", "ZAF"))
})

test_that("simplified and traditional variants resolve to the same code", {
  expect_equal(
    suppressMessages(countryname(c("中国", "中华人民共和国", "中華人民共和國"))),
    c("CHN", "CHN", "CHN")
  )
})

test_that("regional transliterations resolve to the same code", {
  # Montenegro: 黑山 (mainland) vs 蒙特內哥羅 (Taiwan)
  expect_equal(suppressMessages(countryname(c("黑山", "蒙特內哥羅"))), c("MNE", "MNE"))
  # Barbados: 巴巴多斯 (HK) vs 巴貝多 (Taiwan)
  expect_equal(suppressMessages(countryname(c("巴巴多斯", "巴貝多"))), c("BRB", "BRB"))
})

test_that("substring-confusable names are disambiguated, not double-matched", {
  # each pair shares characters but must resolve distinctly
  cases <- c(
    "俄罗斯"   = "RUS", "白俄罗斯"       = "BLR",   # Russia / Belarus
    "几内亚"   = "GIN", "赤道几内亚"     = "GNQ",   # Guinea / Equatorial Guinea
    "几内亚比绍" = "GNB", "巴布亚新几内亚" = "PNG",   # Guinea-Bissau / Papua New Guinea
    "苏丹"     = "SDN", "南苏丹"         = "SSD",   # Sudan / South Sudan
    "尼日尔"   = "NER", "尼日利亚"       = "NGA",   # Niger / Nigeria
    "多米尼克" = "DMA", "多米尼加"       = "DOM"    # Dominica / Dominican Republic
  )
  expect_equal(suppressMessages(countryname(names(cases))), unname(cases))
})

test_that("non-Chinese and ambiguous input return NA", {
  # Latin and Japanese input is ignored; 刚果 is ambiguous (two Congos)
  expect_equal(suppressMessages(countryname(c("Germany", "ドイツ国", "刚果"))),
               rep(NA_character_, 3))
})

test_that("a non-regex origin requires an exact match", {
  expect_equal(
    suppressMessages(countryname("德国", origin = "short_name_zh_cn",
                                 destination = "short_name_en")),
    "Germany"
  )
  # partial match is not enough under exact matching
  expect_equal(
    suppressMessages(countryname("德国人", origin = "short_name_zh_cn",
                                 destination = "short_name_en")),
    NA_character_
  )
})

test_that("destination other than iso3c works", {
  expect_equal(
    suppressMessages(countryname("德国", destination = "short_name_en")),
    "Germany"
  )
})

test_that("the user is told about failures", {
  expect_message(countryname("刚果"), "match")
})
