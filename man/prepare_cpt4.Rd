% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/prepare_cpt4.R
\name{prepare_cpt4}
\alias{prepare_cpt4}
\title{Reconstitute CPT4 Concepts}
\usage{
prepare_cpt4(
  path_to_csvs,
  umls_api_key = Sys.getenv("UMLS_API_KEY"),
  verbose = TRUE
)
}
\arguments{
\item{path_to_csvs}{Path to folder containing the
unpacked vocabularies as csv files, downloaded as a zip
from \url{athena.ohdsi.org}.}

\item{umls_api_key}{API Key given at
\href{https://uts.nlm.nih.gov/uts/profile}{UMLS Licensee Profile}.}

\item{verbose}{If TRUE, prints back activity in the R
console as it is occurring.}
}
\description{
Run the java script that reconstitutes CPT4 concepts
directly from the R console. CPT4 will not be loaded
into Postgres If this is not run beforehand.
}
\details{
A copy of the CONCEPT.csv file is made to CONCEPT_WITHOUT_CPT4.csv
for safekeeping. If the function exits early, the CONCEPT.csv file
is replaced with CONCEPT_WITHOUT_CPT4.csv and the \code{logs} directory
is unlinked recursively. If the function completes, the
CONCEPT_WITHOUT_CPT4.csv is removed instead. This way, the file
would not need to be redownloaded in case something goes wrong
during processing.
}
\seealso{
\code{\link[cli]{cat_line}}
\code{\link[secretary]{typewrite}},
\code{\link[purrr]{map}}
}
