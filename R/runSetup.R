#' @title Run Full Setup
#' @description
#' This function runs the entire process of dropping the target schema if it exists and populating the vocabulary tables.
#' @param conn PARAM_DESCRIPTION, Default: conn
#' @param targetSchema PARAM_DESCRIPTION, Default: 'public'
#' @param cascade PARAM_DESCRIPTION, Default: TRUE
#' @param vocabularyPath PARAM_DESCRIPTION
#' @param verbose PARAM_DESCRIPTION, Default: TRUE
#' @return OUTPUT_DESCRIPTION
#' @details DETAILS
#' @examples
#' \dontrun{
#' if(interactive()){
#'  #EXAMPLE1
#'  }
#' }
#' @seealso
#'  \code{\link[secretary]{typewrite_note}},\code{\link[secretary]{press_enter}},\code{\link[secretary]{typewrite}}
#'  \code{\link[pg13]{lsSchema}},\code{\link[pg13]{createSchema}}
#'  \code{\link[crayon]{crayon}}
#' @rdname runSetup
#' @export
#' @importFrom secretary typewrite_note press_enter typewrite
#' @importFrom pg13 lsSchema createSchema
#' @importFrom crayon italic

runSetup <-
        function(conn = conn,
                 targetSchema = "public",
                 cascade = TRUE,
                 vocabularyPath,
                 verbose = TRUE) {

                if (missing(vocabularyPath)) {
                        stop('vocabularyPath missing with no default')
                }


                secretary::typewrite_note("This process will take approx 30 to 45 minutes.")
                secretary::press_enter()


                if (tolower(targetSchema) %in% tolower(pg13::lsSchema(conn = conn))) {


                                # Dropping and creating new schema
                                if (verbose) {
                                        secretary::typewrite("Dropping and creating new", crayon::italic(targetSchema), "schema...")
                                }

                                clearSchema(conn = conn,
                                                         targetSchema = targetSchema,
                                                         cascade = TRUE)

                } else {

                        if (verbose) {
                                secretary::typewrite("Creating new ", crayon::italic(targetSchema), " schema...")
                        }

                        pg13::createSchema(conn = conn,
                                           schema = targetSchema)

                }



                if (verbose) {
                        secretary::typewrite("Executing DDL...")
                }

                ddl(conn = conn,
                    targetSchema = targetSchema)


                if (verbose) {
                        secretary::typewrite("Copying vocabularies (approx 5 minutes)...", "\n")
                }

                copyVocabularies(vocabularyPath = vocabularyPath,
                                 targetSchema = targetSchema,
                                 conn = conn)

                if (verbose) {

                        secretary::typewrite("Logging Row Counts", "\n")

                }

                logRowCount(conn = conn,
                            targetSchema = targetSchema)


                if (verbose) {
                        secretary::typewrite("Executing indexes (approx 20 minutes)...", "\n")
                }


                indices(conn = conn,
                        targetSchema = targetSchema)


                if (verbose) {
                        secretary::typewrite("Executing constraints (approx 5 minutes)", "\n")
                }

                constraints(conn = conn,
                            targetSchema = targetSchema)


        }
