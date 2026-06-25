test_that("default values work (regex to ISO)", {
  expect_equal(provincename("Innere Mongolei"), "CN-NM")
})

test_that("user-defined destination works", {
  expect_equal(provincename("Innere Mongolei", destination = "short_name_zh"), "内蒙古")
})

test_that("user-defined origin matches exactly, not as regex", {
  expect_warning(provincename("内蒙古", origin = "full_name_zh"))
})

test_that("English, German, Pinyin and Chinese variants resolve to the same code", {
  expect_equal(
    provincename(c("Inner Mongolia", "Innere Mongolei", "内蒙古")),
    rep("CN-NM", 3)
  )
})

test_that("China Customs codes round-trip with ISO codes", {
  # 黑龙江 (Heilongjiang) is customs code 23 and ISO CN-HL
  expect_equal(provincename("黑龙江", destination = "china_customs"), "23")
  expect_equal(provincename("23", origin = "china_customs"), "CN-HL")
})

test_that("non-mainland regions (HK/Macau/Taiwan) are covered", {
  expect_equal(provincename("Hong Kong"), "CN-HK")
  expect_equal(provincename("Macau"), "CN-MO")
  expect_equal(provincename("Taiwan"), "CN-TW")
})

test_that("a sequential destination vector fills in missing values", {
  # type is NA for some rows; fall back to the short English name
  out <- provincename("Hong Kong", destination = c("type", "short_name_en"))
  expect_false(is.na(out))
})
