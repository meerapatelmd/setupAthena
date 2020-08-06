#' Execute Athena DDL
#' @import DatabaseConnector
#' @export

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

