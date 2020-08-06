#' Execute Athena Constraints
#' @import pg13
#' @import SqlRender
#' @export

constraints <-
    function(conn,
             targetSchema) {


        sql <- SqlRender::render(SqlRender::readSql(pg13::sourceFilePath(instSubdir = "sql",
                                                                         FileName = "constraints.sql",
                                                                         package = "setupAthena")),
                                 schema = targetSchema)


        sqlList <- pg13::parseSQL(sql_statement = sql)


        pg13::sendList(conn = conn,
                       sqlList = sqlList)


    }

