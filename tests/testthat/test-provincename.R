test_that("default values work (regex to ISO)", {
  expect_equal(provincename("Innere Mongolei"), "CN-NM")
})

test_that("user-defined destination works", {
  expect_equal(provincename("Innere Mongolei", destination = "short_name_zh"), "内蒙古")
})

test_that("user-defined origin matches exactly, not as regex", {
  expect_warning(provincename("内蒙古", origin = "full_name_zh"))
})
