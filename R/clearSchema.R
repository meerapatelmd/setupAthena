#' Clear the Current Target Schema
#' @param conn A Connection object.
#' @param cascade If TRUE, will drop cascade the schema.
#' @seealso
#'  \code{\link[secretary]{typewrite_warning}},\code{\link[secretary]{press_enter}}
#'  \code{\link[pg13]{dropSchema}},\code{\link[pg13]{createSchema}}
#' @rdname clearSchema
#' @export
#' @importFrom secretary typewrite_warning press_enter
#' @importFrom pg13 dropSchema createSchema


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

                pg13::createSchema(conn = conn,
                                   schema = targetSchema)

        }
