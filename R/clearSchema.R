#' Clear the Current Target Schema
#' @import pg13
#' @param conn A Connection object.
#' @param cascade If TRUE, will drop cascade the schema.
#' @export


clearSchema <-
        function(conn,
                 targetSchema,
                 cascade = FALSE) {


                if (cascade) {
                        secretary::typewrite_warning("DROP", targetSchema, "CASCADE?")
                        secretary::press_enter()
                }

                pg13::dropSchema(conn = conn,
                                 schema = targetSchema,
                                 cascade = cascade)

        }
