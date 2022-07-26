% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/provincename.R
\name{provincename}
\alias{provincename}
\title{Harmonize Province Names}
\usage{
provincename(sourcevar, origin = "regex", destination = "iso_3166_2", ...)
}
\arguments{
\item{sourcevar}{Vector which contains the codes or province names to be
converted (character or factor)}

\item{origin}{A string which identifies the coding scheme of origin (e.g.,
\code{"china_customs"}). See \code{chinautils::province_dict} for a list of available codes.
If not specified, the province name in English, German or Chinese will be matched via regular expressions. Otherwise the match needs to be an exact match (i.e., not just a partial one).}

\item{destination}{A string or vector of strings which identify the coding
scheme of destination (e.g., \code{"type"} or \code{c("gb_2260", "full_name_zh")}).
If not specified, ISO codes will be used. See \code{chinautils::province_dict}
for a list of available codes. When users supply a vector of destination
codes, they are used sequentially to fill in missing values not covered by
the previous destination code in the vector.}

\item{...}{Additional parameters passed on to \code{countrycode::countrycode()}}
}
\value{
A character vector
}
\description{
This is a thin wrapper around \code{countrycode::countrycode()} using a custom
dictionary for Chinese provinces. By default, the province name is matched by
regular expressions and converted into ISO codes.
}
\note{
The list of provinces is based on \href{https://en.wikipedia.org/wiki/ISO_3166-2:CN}{ISO 3166-2:CN} which includes
Taiwan.
}
\examples{
provincename("Innere Mongolei")
provincename("Hong Kong", destination = "full_name_zh")
provincename("Formosa", destination = "type")
}
