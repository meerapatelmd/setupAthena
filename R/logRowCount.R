#' Log Table Row Counts
#' @description
#' This function prints the number of rows for all the vocabulary tables in the R console. The results are also stored alongside a log of all previous data loads in a "setupAthena" cache subdirectory using the caching functions in the R.cache package.
#' @seealso
#'  \code{\link[rubix]{map_names_set}}
#'  \code{\link[pg13]{query}},\code{\link[pg13]{renderRowCount}}
#'  \code{\link[dplyr]{bind}},\code{\link[dplyr]{rename}},\code{\link[dplyr]{mutate}},\code{\link[dplyr]{select}},\code{\link[dplyr]{reexports}}
#'  \code{\link[tidyr]{pivot_wider}}
#'  \code{\link[R.cache]{saveCache}}
#' @rdname logRowCount
#' @export
#' @importFrom rubix map_names_set
#' @importFrom pg13 query renderRowCount
#' @importFrom dplyr bind_rows rename mutate select everything %>%
#' @importFrom tidyr pivot_wider
#' @importFrom R.cache saveCache


logRowCount <-
        function(conn,
                 targetSchema) {

                vocabularyTableNames <- c('ATTRIBUTE_DEFINITION', 'CONCEPT', 'CONCEPT_ANCESTOR', 'CONCEPT_CLASS', 'CONCEPT_RELATIONSHIP', 'CONCEPT_SYNONYM', 'DOMAIN', 'DRUG_STRENGTH', 'RELATIONSHIP', 'SOURCE_TO_CONCEPT_MAP', 'VOCABULARY')

                currentRowCount <-
                        vocabularyTableNames %>%
                        rubix::map_names_set(function(x) pg13::query(conn = conn,
                                                                     sql_statement = pg13::renderRowCount(schema = targetSchema,
                                                                                                          tableName = x))) %>%
                        dplyr::bind_rows(.id = "Table") %>%
                        dplyr::rename(Rows = count)

                cat("\n")
                print(currentRowCount)
                cat("\n")

                historicalRowCount <- loadLog()

                storeCurrentRowCount <-
                currentRowCount %>%
                        tidyr::pivot_wider(names_from = Table,
                                           values_from = Rows) %>%
                        dplyr::mutate(ROWCOUNT_DATETIME = Sys.time()) %>%
                        dplyr::select(ROWCOUNT_DATETIME,
                                      dplyr::everything())

                output <-
                dplyr::bind_rows(historicalRowCount,
                                 storeCurrentRowCount)

                R.cache::saveCache(object = output,
                                   dirs = "setupAthena",
                                   key = list("history"))

        }
