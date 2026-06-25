# chinautils 0.1.0

First documented release.

## New features

* `cc_read_csv()` gained an `encoding` argument and now warns about the
  common pitfalls of China Customs downloads: files truncated at 10,000
  rows, unexpected encodings, unrecognized columns, and -- when several
  files are read together -- columns that are not present in every file
  (such as the date column missing from a single-month update). Files
  without a date column (single-month or aggregated downloads) are read
  without error. The documentation also notes that trade flow is never
  stored in the files, so imports and exports cannot be told apart
  automatically.

## Improvements

* `countryname()` no longer depends on the GitHub-only **ropencc** package.
  Traditional-to-simplified conversion now uses **stringi** (already a
  dependency), so the package installs with a plain `install_github()` and
  has no off-CRAN dependencies. The conversion is unchanged.
* The bundled commodity codes (`cc_commodities`) now cover 2015--2026.
* Added documentation throughout, a pkgdown site, and a vignette on reading
  China Customs trade data.

## Bug fixes

* `cc_read_csv()` no longer errors with "could not find function
  `list_rbind`" on a clean package load, and no longer errors on downloads
  that lack a date column.
* Fixed the data documentation (column listings, row counts) and ensured all
  bundled data is consistently encoded as UTF-8.
