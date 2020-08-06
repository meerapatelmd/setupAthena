#' Execute Athena Constraints
#' @description
#' The constraints are performed using the SQL found at \href{https://raw.githubusercontent.com/OHDSI/CommonDataModel/master/PostgreSQL/OMOP%20CDM%20postgresql%20constraints.txt}{OHDSI OMOP CDM Postgresl Constraints.txt}
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

