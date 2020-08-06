#' Log Table Row Counts
#' @description
#' This function prints the number of rows for all the vocabulary tables in the R console. The results are also stored alongside a log of all previous data loads in a "setupAthena" cache subdirectory using the caching functions in the R.cache package.
#' @importFrom rubix map_names_set
#' @import pg13
#' @importFrom R.cache saveCache loadCache
#' @import tidyr
#' @import dplyr
#' @export

logRowCount <-
        function(conn,
                 targetSchema) {


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
