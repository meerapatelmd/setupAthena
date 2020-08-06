#' Execute Athena Indexes
#' @import pg13
#' @import SqlRender
#' @export

indexes <-
    function(conn,
             targetSchema) {


        sql <- SqlRender::render(SqlRender::readSql(pg13::sourceFilePath(instSubdir = "sql",
                                                                         FileName = "indexes.sql",
                                                                         package = "setupAthena")),
                                 schema = targetSchema)


        sqlList <<- pg13::parseSQL(sql_statement = sql)

        # pg13::sendList(conn = conn,
        #                sqlList = sqlList)


    }

