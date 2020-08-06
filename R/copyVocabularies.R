#' Copy New Vocabulary to Athena
#' @description
#' If CPT4 is desired and has not been unpacked, please do so following the instructions in the README.txt that is in the unpacked vocabulary download.
#' @import secretary
#' @import police
#' @import DatabaseConnector
#' @export


copyVocabularies <-
    function(vocabularyPath,
             cpt4 = TRUE,
             conn) {

        if (!dir.exists(vocabularyPath)) {

            stop('dir "', vocabularyPath, '" does not exist.')

        }

        vocabulary_files <-
            list.files(vocabularyPath,
                       full.names = TRUE,
                       pattern = "[.]csv$")


        if (!cpt4) {

                if (any(grepl("CONCEPT_CPT4.csv", vocabulary_files))) {

                        file.remove(grep("CONCEPT_CPT4.csv", vocabulary_files, value = TRUE))
                        vocabulary_files <-
                            list.files(vocabularyPath,
                                       full.names = TRUE,
                                       pattern = "[.]csv$")
                }

        }

        table_names <- cave::strip_fn(vocabulary_files)

        while (length(vocabulary_files) > 0) {

            vocabulary_file <- vocabulary_files[1]
            table_name <- table_names[1]

            # sql <- paste0("COPY ", table_name, " FROM '", vocabulary_file, "' WITH DELIMITER E'\t' CSV HEADER QUOTE E'\b' ;")

            sql <- SqlRender::render(SqlRender::readSql(pg13::sourceFilePath(instSubdir = "sql",
                                                                             FileName = "copyVocabularies.sql",
                                                                             package = "setupAthena")),
                                     tableName = table_name,
                                     vocabulary_file = vocabulary_file)

            secretary::typewrite("Starting", table_name, "...")

            tryCatch(pg13::send(conn = conn,
                                sql_statement = sql),
                     error = function(err) secretary::typewrite_error(sql))


            secretary::typewrite("Completed", table_name)

            #file.remove(vocabulary_file)
            vocabulary_files <- vocabulary_files[-1]
            table_names <- table_names[-1]

        }

    }
