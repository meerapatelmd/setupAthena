#' Add the MRCONSO UMLS Metathesaurus
#' @param schema name of schema to write to
#' @param drop_schema If TRUE, will drop schema cascade before creating a new schema. If FALSE, the schema parameter must exist.
#' @param filePath path to RRF files
#' @seealso
#'  \code{\link[SqlRender]{render}},\code{\link[SqlRender]{readSql}}
#'  \code{\link[pg13]{sourceFilePath}},\code{\link[pg13]{send}}
#' @rdname addUMLS
#' @export
#' @importFrom SqlRender render readSql
#' @importFrom pg13 sourceFilePath send lsSchema dropSchema createSchema

addUMLS <-
    function(conn,
             schema = "umls",
             drop_schema = TRUE,
             filePath) {

            filePath <- path.expand(filePath)

            if (drop_schema) {
                    Schemas <- pg13::lsSchema(conn = conn)

                    if (schema %in% Schemas) {
                            pg13::dropSchema(conn = conn,
                                             schema = schema,
                                             cascade = TRUE)
                    }

                    pg13::createSchema(conn = conn,
                                       schema = schema)
            }


        sql <- SqlRender::render(SqlRender::readSql(pg13::sourceFilePath(instSubdir = "sql",
                                                                         FileName = "mrconso.sql",
                                                                         package = "setupAthena")),
                                 schema = schema,
                                 filePath = filePath)

        pg13::send(conn = conn,
                   sql_statement = sql)


        for (i in 1:1000000000) {
                if (i == 1) {
                        pos <- vector()
                        failedLines <- list()
                }

                Line <-
                        police::try_catch_error_as_null(
                        readr::read_delim(file = paste0(filePath, "/META/MRCONSO.RRF"),
                                          delim = "|",
                                          skip = i-1,
                                          n_max = 1,
                                          col_names = FALSE))

                if (!is.null(Line)) {
                        if (ncol(Line) == 19) {

                        colnames(Line) <- c('CUI', 'LAT', 'TS', 'LUI', 'STT', 'SUI', 'ISPREF', 'AUI', 'SAUI', 'SCUI', 'SDUI', 'SAB', 'TTY', 'CODE', 'STR', 'SRL', 'SUPPRESS', 'CVF', 'FILLER_COLUMN')

                        pg13::appendTable(conn = conn,
                                          schema = schema,
                                          tableName = "mrconso",
                                          .data = Line)
                        } else {
                                failedLines[[length(failedLines)+1]] <- Line
                        }
                } else {
                        stop("Finished")
                }

        }
    }


