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

        return(sql)
        # pg13::send(conn = conn,
        #            sql_statement = sql)





    }

