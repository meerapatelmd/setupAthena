#' Log Table Row Counts
#' @description
#' This function prints the number of rows for all the vocabulary tables in the R console. The results are also stored alongside a log of all previous data loads in a "setupAthena" cache subdirectory using the caching functions in the R.cache package.
#' @examples
#' \dontrun{
#' if(interactive()){
#'  #EXAMPLE1
#'  }
#' }
#' @seealso
#'  \code{\link[purrr]{map}},\code{\link[purrr]{set_names}}
#'  \code{\link[pg13]{query}},\code{\link[pg13]{renderRowCount}},\code{\link[pg13]{table_exists}},\code{\link[pg13]{send}},\code{\link[pg13]{appendTable}}
#'  \code{\link[dplyr]{bind}},\code{\link[dplyr]{rename}},\code{\link[dplyr]{mutate}},\code{\link[dplyr]{select}},\code{\link[dplyr]{reexports}}
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
                 render_sql = TRUE) {


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



                if (!pg13::table_exists(conn = conn,
                                       schema = "public",
                                       table_name = "setup_athena_log")) {

                        pg13::send(conn = conn,
                                   sql_statement =
                                           "
                                           CREATE TABLE public.setup_athena_log (
                                                sa_datetime TIMESTAMP without TIME ZONE,
                                                CONCEPT_ANCESTOR BIGINT,
                                                CONCEPT_CLASS BIGINT,
                                                CONCEPT_RELATIONSHIP BIGINT,
                                                CONCEPT_SYNONYM BIGINT,
                                                CONCEPT BIGINT,
                                                DOMAIN BIGINT,
                                                DRUG_STRENGTH BIGINT,
                                                RELATIONSHIP BIGINT,
                                                VOCABULARY BIGINT
                                           )
                                                ",
                                   verbose = verbose,
                                   render_sql = render_sql)

                }

                cli::cat_line()
                cli::cat_boxx("Log Results",
                              float = "center")
                print(tibble::as_tibble(current_row_count))
                cli::cat_line()

                current_row_count <-
                        current_row_count %>%
                        tidyr::pivot_wider(names_from = "Table",
                                           values_from = "Rows") %>%
                        dplyr::mutate(sa_datetime = Sys.time()) %>%
                        dplyr::select(sa_datetime,
                                      dplyr::everything())


                pg13::append_table(conn = conn,
                                  schema = "public",
                                  table = "setup_athena_log",
                                  data = current_row_count,
                                  verbose = verbose,
                                  render_sql = render_sql)



        }
