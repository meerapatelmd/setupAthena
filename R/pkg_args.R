#' @title
#' setupAthena Arguments
#'
#' @param path_to_csvs  Path to folder containing the
#' unpacked vocabularies as csv files, downloaded as a zip
#' from \url{athena.ohdsi.org}.
#' @param umls_api_key  UMLS API Key for CPT4 reconstitution.
#' @param conn A Postgres connection object from the
#' DatabaseConnector package. The user must either be a
#' superuser or a member of the pg_read_server_files role.
#' @param conn_fun Character string of the expression used
#' to connect to the target database for the setup. The user
#' must either be a superuser or a member of the
#' pg_read_server_files role.This option automatically
#' closes the connection on exit.
#' @param verbose If TRUE, prints back activity in the R
#' console as it is occurring.
#' @param render_sql If TRUE, the SQL statement is printed
#' back in the R console for reference.
#' @param target_schema Schema where the OMOP Vocabulary
#' Tables will be written to.
#' @param steps Options include c("prepare_cpt4",
#' "drop_tables","copy", "indices", "constraints", "log").
#' Each step corresponds to the function used and may be
#' independently executed.
#' @param release_version Release version as an exact string
#' provided vocabulary download link delivery via email.
#'
#' @name pkg_args
NULL
