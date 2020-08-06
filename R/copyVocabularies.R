#' Copy New Vocabulary to Athena
#' @description
#' If CPT4 is desired and has not been unpacked, please do so following the instructions in the README.txt that is in the unpacked vocabulary download.
#' @import secretary
#' @import police
#' @import pg13
#' @import progress
#' @export



copyVocabularies <-
    function(vocabularyPath,
             targetSchema,
             cpt4 = TRUE,
             conn) {

        if (!dir.exists(vocabularyPath)) {

            stop('dir "', vocabularyPath, '" does not exist.')

        }

        if (missing(conn)) {

            stop('conn is missing with no default')
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

        table_names <- tolower(cave::strip_fn(vocabulary_files))

        totalFiles <- length(vocabulary_files)
        pb <- progress::progress_bar$new(clear = FALSE,
                                         format = ":what [:bar] :elapsedfull :current/:total (:percent)", total = totalFiles)
        pb$tick(0)
        Sys.sleep(0.2)

        for (i in 1:length(vocabulary_files)) {

            vocabulary_file <- vocabulary_files[i]
            table_name <- table_names[i]
            pb$tick(tokens = list(what = table_name))
            Sys.sleep(0.2)

            # sql <- paste0("COPY ", targetSchema, ".", table_name, " FROM '", vocabulary_file, "' WITH DELIMITER E'\t' CSV HEADER QUOTE E'\b' ;")

            sql <- SqlRender::render(SqlRender::readSql(pg13::sourceFilePath(instSubdir = "sql",
                                                                             FileName = "copyVocabularies.sql",
                                                                             package = "setupAthena")),
                                     schema = targetSchema,
                                     tableName = table_name,
                                     vocabulary_file = vocabulary_file)

            tryCatch(pg13::send(conn = conn,
                                sql_statement = sql),
                     error = function(err) secretary::typewrite_error("\n", sql, "\n"))

        }

    }
