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


        .Deprecated(new = "copy")

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





#' Execute Athena DDL
#' @seealso
#'  \code{\link[SqlRender]{render}},\code{\link[SqlRender]{readSql}}
#'  \code{\link[pg13]{sourceFilePath}},\code{\link[pg13]{send}}
#' @rdname ddl
#' @export
#' @importFrom SqlRender render readSql
#' @importFrom pg13 sourceFilePath send

ddl <-
    function(conn,
             targetSchema) {

            .Deprecated()

        sql <- SqlRender::render(SqlRender::readSql(pg13::sourceFilePath(instSubdir = "sql",
                                                                         FileName = "postgresqlddl.sql",
                                                                         package = "setupAthena")),
                                 schema = targetSchema)

        pg13::send(conn = conn,
                   sql_statement = sql)


    }






#' Log Table Row Counts
#' @description
#' This function prints the number of rows for all the vocabulary tables in the R console. The results are also stored alongside a log of all previous data loads in a "setupAthena" cache subdirectory using the caching functions in the R.cache package.
#' @seealso
#'  \code{\link[rubix]{map_names_set}}
#'  \code{\link[pg13]{query}},\code{\link[pg13]{renderRowCount}}
#'  \code{\link[dplyr]{bind}},\code{\link[dplyr]{rename}},\code{\link[dplyr]{mutate}},\code{\link[dplyr]{select}},\code{\link[dplyr]{reexports}}
#'  \code{\link[tidyr]{pivot_wider}}
#'  \code{\link[R.cache]{saveCache}}
#' @rdname logRowCount
#' @export
#' @importFrom rubix map_names_set
#' @importFrom pg13 query renderRowCount
#' @importFrom dplyr bind_rows rename mutate select everything %>%
#' @importFrom tidyr pivot_wider
#' @importFrom R.cache saveCache


logRowCount <-
        function(conn,
                 targetSchema) {

                .Deprecated()

                vocabularyTableNames <- c('ATTRIBUTE_DEFINITION', 'CONCEPT', 'CONCEPT_ANCESTOR', 'CONCEPT_CLASS', 'CONCEPT_RELATIONSHIP', 'CONCEPT_SYNONYM', 'DOMAIN', 'DRUG_STRENGTH', 'RELATIONSHIP', 'SOURCE_TO_CONCEPT_MAP', 'VOCABULARY')

                currentRowCount <-
                        vocabularyTableNames %>%
                        rubix::map_names_set(function(x) pg13::query(conn = conn,
                                                                     sql_statement = pg13::renderRowCount(schema = targetSchema,
                                                                                                          tableName = x))) %>%
                        dplyr::bind_rows(.id = "Table") %>%
                        dplyr::rename(Rows = count)

                cat("\n")
                print(currentRowCount)
                cat("\n")

                historicalRowCount <- loadLog()

                storeCurrentRowCount <-
                currentRowCount %>%
                        tidyr::pivot_wider(names_from = Table,
                                           values_from = Rows) %>%
                        dplyr::mutate(ROWCOUNT_DATETIME = Sys.time()) %>%
                        dplyr::select(ROWCOUNT_DATETIME,
                                      dplyr::everything())

                output <-
                dplyr::bind_rows(historicalRowCount,
                                 storeCurrentRowCount)

                R.cache::saveCache(object = output,
                                   dirs = "setupAthena",
                                   key = list("history"))

        }










#' Load Cached Log
#' @seealso
#'  \code{\link[R.cache]{loadCache}}
#' @rdname loadLog
#' @export
#' @importFrom R.cache loadCache

loadLog <-
        function() {

                R.cache::loadCache(dirs = "setupAthena",
                                   key = list("history"))


        }










#' Rename the current Athena DB
#' @import pg13
#' @param local_dbname Name of a local database other than Athena to connect to to execute the rename SQL statements.
#' @export

renameAthenaDB <-
    function(local_dbname) {

            new_db_name <- paste0("athena", rubix::dated(punct = TRUE))

            conn <- pg13::localConnect(dbname = nonathena_dbname)

            pg13::renameDB(conn = conn,
                           db = "athena",
                           newDB = new_db_name)

            pg13::dc(conn = conn)

    }





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
                 targetSchema = "omop_vocabulary",
                 cascade = TRUE,
                 vocabularyPath,
                 verbose = TRUE) {

                .Deprecated("run_setup")

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

                                pg13::send(conn = conn,
                                           SqlRender::render("DROP SCHEMA @targetSchema CASCADE;", targetSchema = targetSchema))

                } else {

                        if (verbose) {
                                secretary::typewrite("Creating new ", crayon::italic(targetSchema), " schema...")
                        }

                        pg13::createSchema(conn = conn,
                                           schema = targetSchema)

                }

                pg13::send(conn = conn,
                           sql_statement =
                                        "
                                        --HINT DISTRIBUTE ON RANDOM
                                        CREATE TABLE @schema.concept (
                                          concept_id			INTEGER			NOT NULL ,
                                          concept_name			VARCHAR(255)	NOT NULL ,
                                          domain_id				VARCHAR(20)		NOT NULL ,
                                          vocabulary_id			VARCHAR(20)		NOT NULL ,
                                          concept_class_id		VARCHAR(20)		NOT NULL ,
                                          standard_concept		VARCHAR(1)		NULL ,
                                          concept_code			VARCHAR(50)		NOT NULL ,
                                          valid_start_date		DATE			NOT NULL ,
                                          valid_end_date		DATE			NOT NULL ,
                                          invalid_reason		VARCHAR(1)		NULL
                                        )
                                        ;

                                        --HINT DISTRIBUTE ON RANDOM
                                        CREATE TABLE @schema.vocabulary (
                                          vocabulary_id			VARCHAR(20)		NOT NULL,
                                          vocabulary_name		VARCHAR(255)	NOT NULL,
                                          vocabulary_reference	VARCHAR(255)	NOT NULL,
                                          vocabulary_version	VARCHAR(255)	NULL,
                                          vocabulary_concept_id	INTEGER			NOT NULL
                                        )
                                        ;

                                        --HINT DISTRIBUTE ON RANDOM
                                        CREATE TABLE @schema.domain (
                                          domain_id			    VARCHAR(20)		NOT NULL,
                                          domain_name		    VARCHAR(255)	NOT NULL,
                                          domain_concept_id		INTEGER			NOT NULL
                                        )
                                        ;

                                        --HINT DISTRIBUTE ON RANDOM
                                        CREATE TABLE @schema.concept_class (
                                          concept_class_id			VARCHAR(20)		NOT NULL,
                                          concept_class_name		VARCHAR(255)	NOT NULL,
                                          concept_class_concept_id	INTEGER			NOT NULL
                                        )
                                        ;

                                        --HINT DISTRIBUTE ON RANDOM
                                        CREATE TABLE @schema.concept_relationship (
                                          concept_id_1			INTEGER			NOT NULL,
                                          concept_id_2			INTEGER			NOT NULL,
                                          relationship_id		VARCHAR(20)		NOT NULL,
                                          valid_start_date		DATE			NOT NULL,
                                          valid_end_date		DATE			NOT NULL,
                                          invalid_reason		VARCHAR(1)		NULL
                                          )
                                        ;

                                        --HINT DISTRIBUTE ON RANDOM
                                        CREATE TABLE @schema.relationship (
                                          relationship_id			VARCHAR(20)		NOT NULL,
                                          relationship_name			VARCHAR(255)	NOT NULL,
                                          is_hierarchical			VARCHAR(1)		NOT NULL,
                                          defines_ancestry			VARCHAR(1)		NOT NULL,
                                          reverse_relationship_id	VARCHAR(20)		NOT NULL,
                                          relationship_concept_id	INTEGER			NOT NULL
                                        )
                                        ;

                                        --HINT DISTRIBUTE ON RANDOM
                                        CREATE TABLE @schema.concept_synonym (
                                          concept_id			INTEGER			NOT NULL,
                                          concept_synonym_name	VARCHAR(1000)	NOT NULL,
                                          language_concept_id	INTEGER			NOT NULL
                                        )
                                        ;

                                        --HINT DISTRIBUTE ON RANDOM
                                        CREATE TABLE @schema.concept_ancestor (
                                          ancestor_concept_id		INTEGER		NOT NULL,
                                          descendant_concept_id		INTEGER		NOT NULL,
                                          min_levels_of_separation	INTEGER		NOT NULL,
                                          max_levels_of_separation	INTEGER		NOT NULL
                                        )
                                        ;

                                        --HINT DISTRIBUTE ON RANDOM
                                        CREATE TABLE @schema.source_to_concept_map (
                                          source_code				VARCHAR(50)		NOT NULL,
                                          source_concept_id			INTEGER			NOT NULL,
                                          source_vocabulary_id		VARCHAR(20)		NOT NULL,
                                          source_code_description	VARCHAR(255)	NULL,
                                          target_concept_id			INTEGER			NOT NULL,
                                          target_vocabulary_id		VARCHAR(20)		NOT NULL,
                                          valid_start_date			DATE			NOT NULL,
                                          valid_end_date			DATE			NOT NULL,
                                          invalid_reason			VARCHAR(1)		NULL
                                        )
                                        ;

                                        --HINT DISTRIBUTE ON RANDOM
                                        CREATE TABLE @schema.drug_strength (
                                          drug_concept_id				INTEGER		  	NOT NULL,
                                          ingredient_concept_id			INTEGER		  	NOT NULL,
                                          amount_value					NUMERIC		    NULL,
                                          amount_unit_concept_id		INTEGER		  	NULL,
                                          numerator_value				NUMERIC		    NULL,
                                          numerator_unit_concept_id		INTEGER		  	NULL,
                                          denominator_value				NUMERIC		    NULL,
                                          denominator_unit_concept_id	INTEGER		  	NULL,
                                          box_size						INTEGER		 	NULL,
                                          valid_start_date				DATE		    NOT NULL,
                                          valid_end_date				DATE		    NOT NULL,
                                          invalid_reason				VARCHAR(1)  	NULL
                                        )
                                        ;

                                        --HINT DISTRIBUTE ON RANDOM
                                        CREATE TABLE @schema.attribute_definition (
                                          attribute_definition_id		  INTEGER			  NOT NULL,
                                          attribute_name				      VARCHAR(255)	NOT NULL,
                                          attribute_description			  TEXT	NULL,
                                          attribute_type_concept_id		INTEGER			  NOT NULL,
                                          attribute_syntax				    TEXT	NULL
                                        )
                                        ;
                                        "
                                   )


                if (verbose) {
                        secretary::typewrite("Copying vocabularies (approx 5 minutes)...", "\n")
                }

                copyVocabularies(vocabularyPath = vocabularyPath,
                                 targetSchema = targetSchema,
                                 conn = conn)



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





