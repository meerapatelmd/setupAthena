#' @title Run Full Setup
#' @description
#' This function runs the entire process of dropping the target schema if it exists and populating the vocabulary tables.
#' @param conn PARAM_DESCRIPTION, Default: conn
#' @param target_schema PARAM_DESCRIPTION, Default: 'public'
#' @param cascade PARAM_DESCRIPTION, Default: TRUE
#' @param path_to_csvs PARAM_DESCRIPTION
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
#' @rdname run_setup
#' @export
#' @importFrom secretary typewrite_note press_enter typewrite
#' @importFrom pg13 lsSchema createSchema
#' @importFrom crayon italic

run_setup <-
        function(conn,
                 conn_fun,
                 target_schema = "omop_vocabulary",
                 cascade = TRUE,
                 path_to_csvs,
                 verbose = TRUE,
                 render_sql = TRUE) {

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


                # Check csv path

                path_to_csvs <- normalizePath(file.path(path_to_csvs), mustWork = TRUE)


                secretary::typewrite("This process will take approx 30 to 45 minutes.")
                secretary::press_enter()


                if (tolower(target_schema) %in% tolower(pg13::lsSchema(conn = conn))) {


                                # Dropping and creating new schema
                                if (verbose) {
                                        secretary::typewrite("Dropping and creating new", crayon::italic(target_schema), "schema...")
                                }

                                pg13::send(conn = conn,
                                           SqlRender::render("DROP SCHEMA @target_schema CASCADE;", target_schema = target_schema),
                                           verbose = verbose,
                                           render_sql = render_sql)

                } else {

                        if (verbose) {
                                secretary::typewrite("Creating new ", crayon::italic(target_schema), " schema...")
                        }

                        pg13::createSchema(conn = conn,
                                           schema = target_schema)

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


                if (verbose) {
                        secretary::typewrite("Copying vocabularies (approx 5 minutes)...", "\n")
                }

                copyVocabularies(path_to_csvs = path_to_csvs,
                                 target_schema = target_schema,
                                 conn = conn)



                if (verbose) {
                        secretary::typewrite("Executing indexes (approx 20 minutes)...", "\n")
                }


                indices(conn = conn,
                        target_schema = target_schema)


                if (verbose) {
                        secretary::typewrite("Executing constraints (approx 5 minutes)", "\n")
                }

                constraints(conn = conn,
                            target_schema = target_schema)


        }
