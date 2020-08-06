#' Run Update
#' @description
#' This function runs the entire process of dropping the target schema if it exists and populating the vocabulary tables.
#' @importFrom secretary typewrite
#' @export


runProcess <-
        function(conn = conn,
                 targetSchema = "public",
                 cascade = TRUE,
                 vocabularyPath,
                 cpt4 = TRUE,
                 verbose = TRUE) {


                # Dropping and creating new schema
                if (verbose) {
                        secretary::typewrite("Dropping and Creating new ", crayon::italic(targetSchema), " schema...")
                }

                clearSchema(conn = conn,
                                         targetSchema = "public",
                                         cascade = TRUE)

                if (verbose) {
                        secretary::typewrite("DDL...")
                }

                ddl(conn = conn,
                                 targetSchema = "public")


                if (verbose) {
                        secretary::typewrite("Copying vocabularies...", "\n")
                }

                # Time: 5 minutes
                copyVocabularies(vocabularyPath = "~/Desktop/athena",
                                 targetSchema = "public",
                                 conn = conn)

                if (verbose) {
                        secretary::typewrite("Copying vocabularies...", "\n")
                }


        }
