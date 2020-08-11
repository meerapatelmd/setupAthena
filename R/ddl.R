#' Execute Athena DDL
#' @seealso
#'  \code{\link[SqlRender]{render}},\code{\link[SqlRender]{readSql}}
#'  \code{\link[pg13]{sourceFilePath}},\code{\link[pg13]{send}}
#' @rdname ddl
#' @export
#' @importFrom SqlRender render readSql
#' @importFrom pg13 sourceFilePath send

ddl <-
    function(conn,
             targetSchema) {


        sql <- SqlRender::render(SqlRender::readSql(pg13::sourceFilePath(instSubdir = "sql",
                                                                         FileName = "postgresqlddl.sql",
                                                                         package = "setupAthena")),
                                 schema = targetSchema)

        pg13::send(conn = conn,
                   sql_statement = sql)


    }

