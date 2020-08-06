#' Execute Athena Constraints
#' @import pg13
#' @import SqlRender
#' @export

constraints <-
    function(conn,
             targetSchema) {


        sql <- SqlRender::render(SqlRender::readSql(pg13::sourceFilePath(instSubdir = "sql",
                                                                         FileName = "indexes.sql",
                                                                         package = "setupAthena")),
                                 schema = targetSchema)

        pg13::send(conn = conn,
                   sql_statement = sql)


    }

