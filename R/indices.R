#' Execute Athena Indexes
#' @description
#' SQL for indices derived from \href{"https://raw.githubusercontent.com/OHDSI/CommonDataModel/master/PostgreSQL/OMOP%20CDM%20postgresql%20pk%20indexes.txt"}{OHDSI OMOP CDM PK Indexes.txt}
#' @import pg13
#' @import SqlRender
#' @export

indices <-
    function(conn,
             targetSchema) {


        sql <- SqlRender::render(SqlRender::readSql(pg13::sourceFilePath(instSubdir = "sql",
                                                                         FileName = "indices.sql",
                                                                         package = "setupAthena")),
                                 schema = targetSchema)


        sqlList <- pg13::parseSQL(sql_statement = sql)

        pg13::sendList(conn = conn,
                       sqlList = sqlList)


    }

