#' Copy New Vocabulary to Athena
#' @description
#' This function copies a freshly downloaded and unpacked vocabulary export from \href{athena.ohdsi.org}{Athena}.
#' If CPT4 is included in the downloaded bundle and has not been reconstituted, please do so following the instructions in the README.txt that is in the unpacked vocabulary download. Otherwise, CPT4 will not be included in the new concept table. The reconstitution process is logged within the same vocabulary folder and a warning is returned in the R console if there is no evidence of a log file recursively in the same folder.
#'  \code{\link[cave]{strip_fn}}
#'  \code{\link[progress]{progress_bar}}
#'  \code{\link[SqlRender]{render}},\code{\link[SqlRender]{readSql}}
#'  \code{\link[pg13]{sourceFilePath}},\code{\link[pg13]{send}}
#'  \code{\link[secretary]{typewrite_error}}
#' @rdname copyVocabularies
#' @export
#' @importFrom cave strip_fn
#' @importFrom progress progress_bar
#' @importFrom SqlRender render readSql
#' @importFrom pg13 sourceFilePath send
#' @importFrom secretary typewrite_error



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
                c("CONCEPT_ANCESTOR.csv",
                  "CONCEPT_CLASS.csv",
                  "CONCEPT_RELATIONSHIP.csv",
                  "CONCEPT_SYNONYM.csv",
                  "CONCEPT.csv",
                  "DOMAIN.csv",
                  "DRUG_STRENGTH.csv",
                  "RELATIONSHIP.csv",
                  "VOCABULARY.csv")

        vocabularyPaths <- path.expand(file.path(vocabularyPath, vocabulary_files))

        table_names <- tolower(cave::strip_fn(vocabularyPaths))


        pb <- progress::progress_bar$new(clear = FALSE,
                                         format = ":what [:bar] :elapsedfull :current/:total (:percent)", total = length(table_names))
        pb$tick(0)
        Sys.sleep(0.2)


        errors <- vector()

        for (i in 1:length(vocabularyPaths)) {

            vocabulary_file <- vocabularyPaths[i]
            table_name <- table_names[i]
            pb$tick(tokens = list(what = table_name))
            Sys.sleep(0.2)

            # sql <- paste0("COPY ", targetSchema, ".", table_name, " FROM '", vocabulary_file, "' WITH DELIMITER E'\t' CSV HEADER QUOTE E'\b' ;")

            sql <- SqlRender::render("COPY @schema.@tableName FROM '@vocabulary_file' WITH DELIMITER E'\t' CSV HEADER QUOTE E'\b';",
                                     schema = targetSchema,
                                     tableName = table_name,
                                     vocabulary_file = vocabulary_file)

            output <-
            tryCatch(pg13::send(conn = conn,
                                sql_statement = sql),
                     error = function(e) "Error")

            if (length(output) == 1 && output == "Error") {
                         errors <-
                             c(errors,
                               table_name = sql)
            }

        }

        if (length(errors)) {

            warning("Some tables failed to load: ", errors)
        }

    }
