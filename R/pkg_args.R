#' @title
#' setupAthena Arguments
#'
#' @param path_to_csvs  Path to folder containing the unpacked vocabularies as csv files, downloaded as a zip from \url{athena.ohdsi.org}.
#' @param umls_api_key  UMLS API Key for CPT4 reconstitution.
#' @inheritParams pg13::query
#' @inheritParams pg13::send
#' @param target_schema Schema where the OMOP Vocabulary ('Athena') Tables will be written to.
#' @param steps Options include c("prepare_cpt4", "drop_tables","copy", "indices", "constraints", "log"). Each step corresponds to the function used and may be independently executed. \code{\link{prepare_cpt4}} is not included in default because of its tendency to run slow and the java script used to reconstitute the CPT4 needs to run uninterrupted or else the resulting CONCEPT.csv file will be damaged. Therefore, it is advised to reconstitute CPT4 separately from the Command Line or using the aforementioned function in this package though the option to do it as part of \code{\link{run_setup}} is available.
#'
#' @name pkg_args
NULL
