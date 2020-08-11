#' Execute Athena Constraints
#' @description
#' The constraints are performed using the SQL found at \href{https://raw.githubusercontent.com/OHDSI/CommonDataModel/master/PostgreSQL/OMOP%20CDM%20postgresql%20constraints.txt}{OHDSI OMOP CDM Postgresl Constraints}
#' @seealso
#'  \code{\link[SqlRender]{render}},\code{\link[SqlRender]{readSql}}
#'  \code{\link[pg13]{sourceFilePath}},\code{\link[pg13]{parseSQL}},\code{\link[pg13]{sendList}}
#' @rdname constraints
#' @export
#' @importFrom SqlRender render readSql
#' @importFrom pg13 sourceFilePath parseSQL sendList

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

