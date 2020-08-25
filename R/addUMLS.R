#' Add the MRCONSO UMLS Metathesaurus
#' @seealso
#'  \code{\link[SqlRender]{render}},\code{\link[SqlRender]{readSql}}
#'  \code{\link[pg13]{sourceFilePath}},\code{\link[pg13]{send}}
#' @rdname ddl
#' @export
#' @importFrom SqlRender render readSql
#' @importFrom pg13 sourceFilePath send

addUMLS <-
    function(conn) {

            schema <- "umls"
            pg13::dropSchema(conn = conn,
                             schema = schema)

        sql <- SqlRender::render(SqlRender::readSql(pg13::sourceFilePath(instSubdir = "sql",
                                                                         FileName = "umlsddl.sql",
                                                                         package = "setupAthena")),
                                 schema = schema)

        pg13::send(conn = conn,
                   sql_statement = sql)


    }

