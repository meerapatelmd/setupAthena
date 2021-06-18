#' @title
#' Log Update
#'
#' @description
#' This function prints the number of rows for all the
#' vocabulary tables in the R console.
#'
#' @seealso
#'  \code{\link[purrr]{map}},
#'  \code{\link[purrr]{set_names}}
#'  \code{\link[pg13]{query}},
#'  \code{\link[pg13]{renderRowCount}},
#'  \code{\link[pg13]{table_exists}},
#'  \code{\link[pg13]{send}},
#'  \code{\link[pg13]{appendTable}}
#'  \code{\link[dplyr]{bind}},
#'  \code{\link[dplyr]{rename}},
#'  \code{\link[dplyr]{mutate}},
#'  \code{\link[dplyr]{select}},
#'  \code{\link[dplyr]{reexports}}
#'  \code{\link[cli]{cat_line}}
#'  \code{\link[tibble]{as_tibble}}
#'  \code{\link[tidyr]{pivot_wider}}
#' @rdname log
#' @export
#' @importFrom purrr map set_names
#' @importFrom pg13 query renderRowCount table_exists send appendTable
#' @importFrom dplyr bind_rows rename mutate select everything
#' @importFrom cli cat_line cat_boxx
#' @importFrom tibble as_tibble
#' @importFrom tidyr pivot_wider

log <-
        function(conn,
                 target_schema,
                 verbose = TRUE,
                 render_sql = TRUE,
                 release_version) {


                table_names <-
                        c("CONCEPT_ANCESTOR",
                          "CONCEPT_CLASS",
                          "CONCEPT_RELATIONSHIP",
                          "CONCEPT_SYNONYM",
                          "CONCEPT",
                          "DOMAIN",
                          "DRUG_STRENGTH",
                          "RELATIONSHIP",
                          "VOCABULARY")

                current_row_count <-
                        table_names %>%
                        purrr::map(function(x) pg13::query(conn = conn,
                                                                     sql_statement = pg13::renderRowCount(schema = target_schema,
                                                                                                          tableName = x))) %>%
                        purrr::set_names(table_names) %>%
                        dplyr::bind_rows(.id = "Table") %>%
                        dplyr::rename(Rows = count)


                cli::cat_line()
                cli::cat_boxx("Log Results",
                              float = "center")
                print(tibble::as_tibble(current_row_count))
                cli::cat_line()


                new_log_entry <-
                        current_row_count %>%
                        tidyr::pivot_wider(names_from = "Table",
                                           values_from = "Rows") %>%
                        dplyr::mutate(sa_datetime = Sys.time()) %>%
                        dplyr::mutate(sa_release_version = release_version) %>%
                        dplyr::mutate(sa_schema = target_schema) %>%
                        dplyr::select(sa_datetime,
                                      sa_release_version,
                                      sa_schema,
                                      dplyr::everything())


                if (pg13::table_exists(conn = conn,
                                        schema = "public",
                                        table_name = "setup_athena_log")) {

                old_log <-
                        pg13::read_table(conn = conn,
                                         schema = "public",
                                         table = "setup_athena_log",
                                         verbose = verbose,
                                         render_sql = render_sql)


                new_log <-
                        dplyr::bind_rows(old_log,
                                         new_log_entry)


                pg13::drop_table(conn = conn,
                                 schema = "public",
                                 table = "setup_athena_log",
                                 verbose = verbose,
                                 render_sql = render_sql)

                } else {
                        new_log <- new_log_entry
                }

                pg13::write_table(conn = conn,
                                  schema = "public",
                                  table = "setup_athena_log",
                                  data =    new_log,
                                  verbose = verbose,
                                  render_sql = render_sql)



        }
