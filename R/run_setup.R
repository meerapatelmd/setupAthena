#' @title
#' Run Athena Setup
#'
#' @description
#' Stepwise process of instantiating the Athena Vocabularies. Steps can be skipped using the `steps` argument though the order cannot be changed.
#'
#' @inheritParams pkg_args
#' @return
#' Updated OMOP Vocabulary (Athena) CONCEPT_ANCESTOR, CONCEPT_CLASS, CONCEPT_RELATIONSHIP, CONCEPT_SYNONYM, CONCEPT, DOMAIN, DRUG_STRENGTH, RELATIONSHIP, and VOCABULARY Tables in the given target schema.
#' @seealso
#'  \code{\link[rlang]{parse_expr}}
#'  \code{\link[pg13]{dc}},\code{\link[pg13]{is_conn_open}},\code{\link[pg13]{lsSchema}},\code{\link[pg13]{dropTable}},\code{\link[pg13]{send}}
#'  \code{\link[cli]{cat_line}}
#'  \code{\link[secretary]{typewrite}}
#'  \code{\link[SqlRender]{render}}
#' @rdname run_setup
#' @export
#' @importFrom rlang parse_expr
#' @importFrom pg13 dc is_conn_open lsSchema dropTable send
#' @importFrom cli cat_line cat_boxx
#' @importFrom secretary typewrite
#' @importFrom SqlRender render

run_setup <-
        function(conn,
                 conn_fun,
                 target_schema = "omop_vocabulary",
                 steps = c("drop_tables",
                           "copy",
                           "indices",
                           "constraints",
                           "log"),
                 path_to_csvs,
                 umls_api_key,
                 verbose = TRUE,
                 render_sql = TRUE) {

                # Check csv path
                path_to_csvs <- normalizePath(file.path(path_to_csvs), mustWork = TRUE)

                # Checking Connection
                if (!missing(conn_fun)) {

                        conn <- eval(rlang::parse_expr(conn_fun))
                        on.exit(pg13::dc(conn = conn,
                                         verbose = verbose),
                                add = TRUE,
                                after = TRUE)

                }

                if (!pg13::is_conn_open(conn = conn)) {

                        stop("`conn` is not open.")

                }

                # Prepare CPT4

                if ("prepare_cpt4" %in% steps) {

                        if (missing(umls_api_key)) {

                                umls_api_key <- readline(prompt = "UMLS API Key: ")

                        }

                        prepare_cpt4(path_to_csvs = path_to_csvs,
                                     umls_api_key = umls_api_key,
                                     verbose = verbose)

                }

                if ("drop_tables" %in% steps) {

                        if (verbose) {

                                cli::cat_line()
                                cli::cat_boxx(sprintf("Drop Tables in '%s' Schema", target_schema))
                        }


                        if (tolower(target_schema) %in% tolower(pg13::lsSchema(conn = conn,
                                                                               verbose = verbose,
                                                                               render_sql = render_sql))) {


                                # Dropping and creating new schema
                                if (verbose) {
                                        secretary::typewrite(sprintf("Existing '%s' schema found. Dropping tables...", target_schema))
                                }

                                table_names <-
                                        c("CONCEPT_ANCESTOR",
                                          "CONCEPT_CLASS",
                                          "CONCEPT_RELATIONSHIP",
                                          "CONCEPT_SYNONYM",
                                          "CONCEPT",
                                          "DOMAIN",
                                          "DRUG_STRENGTH",
                                          "RELATIONSHIP",
                                          "VOCABULARY")

                                for (i in seq_along(table_names)) {

                                        pg13::dropTable(conn = conn,
                                                        schema = target_schema,
                                                        tableName = table_names[i],
                                                        verbose = verbose,
                                                        render_sql = render_sql)

                                }


                        }



                pg13::send(conn = conn,
                           sql_statement =
                                   SqlRender::render(
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
                                        ",
                                        schema = target_schema
                                   ))

                }



                if ("copy" %in% steps) {


                        if (verbose) {
                                cli::cat_line()
                                cli::cat_boxx("Copy")

                                secretary::typewrite("Copying vocabularies...")

                        }


                        copy(path_to_csvs = path_to_csvs,
                             target_schema = target_schema,
                             conn = conn,
                             verbose = verbose,
                             render_sql = render_sql)

                }


                if ("indices" %in% steps) {


                        if (verbose) {

                                cli::cat_line()
                                cli::cat_boxx("Indices")
                                secretary::typewrite("Executing indexes...")
                        }


                        indices(conn = conn,
                                target_schema = target_schema,
                                verbose = verbose,
                                render_sql = render_sql)
                }



                if ("constraints" %in% steps) {


                        if (verbose) {
                                cli::cat_line()
                                cli::cat_boxx("Constraints")
                                secretary::typewrite("Executing constraints...")
                        }

                        constraints(conn = conn,
                                    target_schema = target_schema,
                                    verbose = verbose,
                                    render_sql = render_sql)

                }

                if ("log" %in% steps) {

                        if (verbose) {
                                cli::cat_line()
                                cli::cat_boxx("Log")
                                secretary::typewrite("Logging...")
                        }

                        log(conn = conn,
                            target_schema = target_schema,
                            verbose = verbose,
                            render_sql = render_sql)

                }

        }

