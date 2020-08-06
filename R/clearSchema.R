#' Clear the Current Target Schema
#' @import pg13
#' @param conn A Connection object.
#' @param drop If TRUE, will drop the schema if it exists.
#' @export


clearSchema <-
        function(conn,
                 targetSchema,
                 drop = FALSE) {


                secretary::typewrite_warning("DROP", targetSchema, "CASCADE?")
                secretary::press_enter()

                if (drop) {
                        pg13::send(conn = conn,
                                   sql_statement = pg13::renderDropSchema(schema = targetSchema))
                }

                pg13::send(conn = conn,
                            sql_statement = pg13::renderCreateSchema(schema = targetSchema))
        }
