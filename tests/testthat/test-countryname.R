test_that("input order is preserved in the presence of duplicates", {
  input <- c("南非", "德国", "南非")
  expect_equal(chinautils::countryname(input), c("ZAF", "DEU", "ZAF"))
})
