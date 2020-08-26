#' @title Load MRCONSO Table
#' @description FUNCTION_DESCRIPTION
#' @param filePath PARAM_DESCRIPTION
#' @param max_lines PARAM_DESCRIPTION
#' @param conn PARAM_DESCRIPTION
#' @param schema PARAM_DESCRIPTION
#' @return OUTPUT_DESCRIPTION
#' @details DETAILS
#' @examples
#' \dontrun{
#' if(interactive()){
#'  #EXAMPLE1
#'  }
#' }
#' @seealso
#'  \code{\link[progress]{progress_bar}}
#'  \code{\link[readr]{read_delim}}
#'  \code{\link[pg13]{appendTable}}
#' @rdname loadMRCONSO
#' @export
#' @importFrom progress progress_bar
#' @importFrom readr read_delim
#' @importFrom pg13 appendTable

loadMRCONSO <-
        function(filePath,
                 max_lines,
                 conn,
                 schema) {
                filePath <- path.expand(filePath)

                pb <- progress::progress_bar$new(format = "[:bar] :percent :elapsedfull",
                                                 total = max_lines)


                pb$tick(0)
                Sys.sleep(0.2)


                for (i in 1:max_lines) {
                        if (i == 1) {
                                pos <- vector()
                                failedLines <- list()
                        }

                        Line <-
                                readr::read_delim(file = paste0(filePath, "/MRCONSO.RRF"),
                                                          delim = "|",
                                                          skip = i-1,
                                                          n_max = 1,
                                                          col_names = FALSE)

                                if (ncol(Line) == 19) {

                                        colnames(Line) <- c('CUI', 'LAT', 'TS', 'LUI', 'STT', 'SUI', 'ISPREF', 'AUI', 'SAUI', 'SCUI', 'SDUI', 'SAB', 'TTY', 'CODE', 'STR', 'SRL', 'SUPPRESS', 'CVF', 'FILLER_COLUMN')

                                        pg13::appendTable(conn = conn,
                                                          schema = schema,
                                                          tableName = "mrconso",
                                                          .data = Line)

                                        pb$tick()
                                        Sys.sleep(0.2)
                                } else {
                                        failedLines[[length(failedLines)+1]] <- Line
                                        failedLines <<- failedLines
                                        pb$tick()
                                        Sys.sleep(0.2)
                                }

                }
        }
