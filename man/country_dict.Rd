% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/data.R
\docType{data}
\name{country_dict}
\alias{country_dict}
\title{Concordance table of country names and codes.}
\format{
A data frame with 208 rows and 15 variables:
\describe{
\item{short_name_en}{Short country name in English}
\item{iso3c}{ISO3 character country code}
\item{regex}{regular expressions to match short and full country names (as well as variants thereof) after conversion to simplified characters}
\item{short_name_zh_}{Short country name in Chinese. See details for region codes.}
\item{full_name_zh_}{Full (official) country name in Chinese. See details for region codes.}
}
}
\source{
\url{https://github.com/turbanisch/chinese-countryname-regex}
\url{https://zh.wikipedia.org/wiki/世界政區索引}
}
\usage{
country_dict
}
\description{
A dataset containing country names in Chinese and regular expressions to match them. Each set of names in Chinese includes short and full country names in simplified and traditional scripts as used in Mainland China, Malaysia, Singapore, Hong Kong, Macau and Taiwan. The dataset additionally includes English (short) country names and ISO3 codes for harmonization purposes.
}
\details{
\tabular{lll}{
   Code \tab Description (Chinese) \tab Description (English) \cr
   cn \tab 大陆简体 \tab Mainland (simplified) \cr
   hk \tab 香港繁體 \tab Hong Kong (traditional) \cr
   mo \tab 澳門繁體 \tab Macau (traditional) \cr
   my \tab 大马简体 \tab Malaysia (simplified) \cr
   sg \tab 新加坡简体 \tab Singapore (simplified) \cr
   tw \tab 臺灣正體 \tab Taiwan (traditional) \cr
}
}
\keyword{datasets}
