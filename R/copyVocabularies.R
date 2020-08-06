#' Copy New Vocabulary to Athena
#' @description
#' This function copies a freshly downloaded and unpacked vocabulary export from \href{athena.ohdsi.org}{Athena}.
#' If CPT4 is included in the downloaded bundle and has not been reconstituted, please do so following the instructions in the README.txt that is in the unpacked vocabulary download. Otherwise, CPT4 will not be included in the new concept table. The reconstitution process is logged within the same vocabulary folder and a warning is returned in the R console if there is no evidence of a log file recursively in the same folder.
#' @import secretary
#' @import police
#' @import pg13
#' @import progress
#' @export



copyVocabularies <-
    function(vocabularyPath,
             targetSchema,
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


        if (any(grepl("CONCEPT_CPT4.csv", vocabulary_files))) {

                file.remove(grep("CONCEPT_CPT4.csv", vocabulary_files, value = TRUE))
                vocabulary_files <-
                    list.files(vocabularyPath,
                               full.names = TRUE,
                               pattern = "[.]csv$")

                logFiles <-
                list.files(vocabularyPath,
                           full.names = TRUE,
                           recursive = TRUE,
                           pattern = "[.]{1}log$")

                if (!length(logFiles)) {

                        warning("'vocabularyPath' does not contain a log file suggesting that CPT4 has been reconstituted")

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
