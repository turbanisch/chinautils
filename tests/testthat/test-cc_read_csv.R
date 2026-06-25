fixture <- function(name) system.file("extdata", name, package = "chinautils")

test_that("reads a full English file with harmonized names and types", {
  out <- cc_read_csv(fixture("english-full.csv"))

  expect_s3_class(out, "tbl_df")
  expect_setequal(
    colnames(out),
    c("yearmonth", "commodity", "partner", "regime", "province",
      "quantity_1", "unit_1", "quantity_2", "unit_2", "value_usd")
  )
  # codes stay character (leading zeros matter), dates are parsed, value numeric
  expect_s3_class(out$yearmonth, "Date")
  expect_type(out$commodity, "character")
  expect_type(out$value_usd, "double")
})

test_that("column order does not affect the result (permutation invariance)", {
  straight <- cc_read_csv(fixture("english-full.csv"))
  permuted <- cc_read_csv(fixture("english-full-permutated.csv"))

  expect_setequal(colnames(straight), colnames(permuted))
  # same data once aligned to a common column order
  ord <- sort(colnames(straight))
  expect_equal(straight[ord], permuted[ord])
})

test_that("English and Chinese files harmonize to the same clean names", {
  en <- cc_read_csv(fixture("english-full.csv"))
  zh <- cc_read_csv(fixture("chinese-full.csv"))

  shared <- c("commodity", "partner", "regime", "province",
              "quantity_1", "unit_1", "quantity_2", "unit_2")
  expect_true(all(shared %in% colnames(en)))
  expect_true(all(shared %in% colnames(zh)))
})

test_that("GB18030 Chinese content is decoded correctly", {
  zh <- cc_read_csv(fixture("chinese-full.csv"))
  # 千克 = "kilogram"; presence proves the encoding round-tripped
  expect_true(any(zh$unit_1 == "千克"))
})

test_that("single-month / month-less downloads are handled without error", {
  # degenerate single-month download omits the date column entirely
  degen <- cc_read_csv(fixture("english-degenerate.csv"))
  expect_false("yearmonth" %in% colnames(degen))
  expect_identical(nrow(degen), 3L)

  # a multi-month aggregate can also lack the date column
  zh <- cc_read_csv(fixture("chinese-full.csv"))
  expect_false("yearmonth" %in% colnames(zh))
})

test_that("multiple files of different shape/language bind together", {
  # files differ (Chinese lacks yearmonth, uses value_cny) -> warns
  expect_warning(
    out <- cc_read_csv(fixture(c("english-full.csv", "chinese-full.csv"))),
    "same columns"
  )
  # union of columns; currency columns stay separate (never summed)
  expect_true(all(c("value_usd", "value_cny") %in% colnames(out)))
  expect_identical(nrow(out), 10L) # 5 + 5 trimmed fixtures
})

test_that("binding files with inconsistent columns warns, naming yearmonth", {
  # appending a single-month update (no date column) to a dated series
  expect_warning(
    cc_read_csv(fixture(c("english-full.csv", "english-degenerate.csv"))),
    "yearmonth"
  )
})

test_that("binding files with identical columns does not warn", {
  expect_no_warning(
    cc_read_csv(fixture(c("english-full.csv", "english-full-permutated.csv")))
  )
})

test_that("drop_descriptions toggles the *_name columns", {
  kept <- cc_read_csv(fixture("english-full.csv"), drop_descriptions = FALSE)
  expect_true(any(endsWith(colnames(kept), "_name")))

  dropped <- cc_read_csv(fixture("english-full.csv"), drop_descriptions = TRUE)
  expect_false(any(endsWith(colnames(dropped), "_name")))
})

test_that("wrong encoding aborts with a helpful message", {
  # the Chinese file is GB18030; forcing UTF-8 cannot decode it
  expect_error(
    cc_read_csv(fixture("chinese-full.csv"), encoding = "UTF-8"),
    "decode|encoding"
  )
})

test_that("unrecognized columns warn but are still read", {
  tmp <- withr::local_tempfile(fileext = ".csv")
  writeLines(
    c("\"Commodity code\",\"Mystery column\",\"US dollar\",",
      "\"29012920\",\"x\",\"100\","),
    tmp
  )
  expect_warning(out <- cc_read_csv(tmp), "Unrecognized")
  expect_true("Mystery column" %in% colnames(out))
})

test_that("a file with exactly 10,000 rows warns about truncation", {
  tmp <- withr::local_tempfile(fileext = ".csv")
  writeLines(
    c("\"Commodity code\",\"US dollar\",",
      sprintf("\"29012920\",\"%d\",", seq_len(10000))),
    tmp
  )
  expect_warning(cc_read_csv(tmp), "10,000")
})
