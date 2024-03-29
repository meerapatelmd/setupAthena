#' @title
#' Run Athena Setup
#'
#' @description
#' Stepwise process of instantiating the Athena Vocabularies.
#' Steps can be skipped using the `steps` argument though
#' the order cannot be changed.
#'
#' @inheritParams pkg_args
#' @return
#' Updated OMOP Vocabulary (Athena) CONCEPT_ANCESTOR, C
#' ONCEPT_CLASS, CONCEPT_RELATIONSHIP, CONCEPT_SYNONYM,
#' CONCEPT, DOMAIN, DRUG_STRENGTH, RELATIONSHIP, and
#' VOCABULARY Tables in the given target schema.
#'
#' @rdname run_setup
#' @export
#' @importFrom rlang parse_expr
#' @importFrom pg13 dc ls_schema drop_cascade create_schema send
#' @importFrom cli cat_line cat_boxx cli_alert_warning
#' @importFrom secretary typewrite press_enter
#' @importFrom SqlRender render
#' @importFrom chariotViz get_version_key setup_chariotViz

run_setup <-
  function(conn,
           conn_fun = "pg13::local_connect()",
           target_schema = "omop_athena",
           steps = c(
             "drop_tables",
             "copy",
             "log",
             "indices",
             "constraints",
             "chariotviz_cache"
           ),
           postprocessing =
             c("omop_atc_classification"),
           path_to_csvs,
           release_version,
           umls_api_key = Sys.getenv("UMLS_API_KEY"),
           verbose = TRUE,
           render_sql = TRUE,
           render_only = FALSE,
           checks = "") {

    # Checking Connection
    if (missing(conn)) {
      conn <- eval(rlang::parse_expr(conn_fun))
      on.exit(pg13::dc(
        conn = conn,
        verbose = verbose
      ),
      add = TRUE,
      after = TRUE
      )
    }

    # Get current version already loaded into the database from the
    # log
    if (pg13::table_exists(conn = conn,
                           schema = "public",
                           table = "setup_athena_log")) {
    db_version <-
    get_version(conn = conn,
                conn_fun = conn_fun,
                verbose = verbose,
                render_sql = render_sql,
                render_only = render_only,
                checks = checks)

    if (identical(db_version, release_version)) {

      if (interactive()) {
      cli::cli_alert_warning("The release_version '{release_version}' has already been logged. Continue? ")
      secretary::press_enter()

      }

    }

    }

    steps_requiring_csvs <-
      c("drop_tables",
        "copy",
        "prepare_cpt4")

    if (any(steps_requiring_csvs %in% steps)) {
      if (missing(path_to_csvs)) {
        stop("`path_to_csvs` required before dropping or for copying.",
          call. = FALSE
        )
      }
    }

    if (any(steps_requiring_csvs %in% steps)) {
    # Check csv path
    path_to_csvs <-
      normalizePath(file.path(path_to_csvs),
        mustWork = TRUE
      )
    }

    # Prepare CPT4
    if ("prepare_cpt4" %in% steps) {
      if (missing(umls_api_key)) {
        umls_api_key <- readline(prompt = "UMLS API Key: ")
      }

      prepare_cpt4(
        path_to_csvs = path_to_csvs,
        umls_api_key = umls_api_key,
        verbose = verbose
      )
    } else if (any(c("drop_tables", "copy") %in% steps)) {
      if (!("logs" %in% list.files(path_to_csvs))) {
        readline("No record of CPT4 processing found in `path_to_csvs`. Continue? ")
      }
    }

    # If log is a step, release_version must be present
    if ("log" %in% steps) {
      if (missing(release_version)) {
        stop("`release_version` required",
          call. = FALSE
        )
      }
    }



    if ("drop_tables" %in% steps) {
      if (verbose) {
        cli::cat_line()
        cli::cat_boxx("Drop Tables",
          float = "center"
        )
      }


      if (tolower(target_schema) %in% tolower(pg13::ls_schema(
        conn = conn,
        verbose = verbose,
        render_sql = render_sql
      ))) {


        # Dropping and creating new schema
        if (verbose) {
          secretary::typewrite(sprintf("Existing '%s' schema found. Dropping tables...", target_schema))
        }

        pg13::drop_cascade(
          conn = conn,
          schema = target_schema
        )

        # Dropping and creating new schema
        if (verbose) {
          secretary::typewrite("Tables dropped.")
        }
      }

      pg13::create_schema(
        conn = conn,
        schema = target_schema
      )

      # Dropping and creating new schema
      if (verbose) {
        secretary::typewrite(sprintf("'%s' schema created.", target_schema))
      }

      if (verbose) {
        secretary::typewrite("Creating tables...")
      }


      pg13::send(
        conn = conn,
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
          )
      )

      if (verbose) {
        secretary::typewrite("Tables created.")
      }
    }



    if ("copy" %in% steps) {
      if (verbose) {
        cli::cat_line()
        cli::cat_boxx("Copy",
          float = "center"
        )

        secretary::typewrite("Copying...")
      }


      copy(
        path_to_csvs = path_to_csvs,
        target_schema = target_schema,
        conn = conn,
        verbose = verbose,
        render_sql = render_sql
      )
    }

    if ("log" %in% steps) {
      if (verbose) {
        cli::cat_line()
        cli::cat_boxx("Log",
                      float = "center"
        )
        secretary::typewrite("Logging...")
      }

      log(
        conn = conn,
        target_schema = target_schema,
        release_version = release_version,
        verbose = verbose,
        render_sql = render_sql
      )
    }


    if ("indices" %in% steps) {
      if (verbose) {
        cli::cat_line()
        cli::cat_boxx("Indices",
          float = "center"
        )
        secretary::typewrite("Executing indexes...")
      }


      indices(
        conn = conn,
        target_schema = target_schema,
        verbose = verbose,
        render_sql = render_sql
      )
    }

    if ("omop_atc_classification" %in% postprocessing) {

      postprocessing_file <-
        system.file(package = "setupAthena",
                    "sql",
                    "postprocessing",
                    "omop_atc_classification.sql")

      sql_statement <-
        paste(readLines(postprocessing_file),
              collapse = "\n")
      sql_statement <-
        glue::glue(sql_statement)

      rs <-
        tryCatch(
          pg13::send(
            conn = conn,
            sql_statement = sql_statement,
            verbose = verbose,
            render_sql = render_sql
          ),
          error = function(e) "Error"
        )

      if (identical(rs, "Error")) {

        secretary::typewrite(
          cli::cli_alert_danger("Postprocessing job '{postprocessing[i]}' failed.")
        )


      }

    }




    if ("constraints" %in% steps) {
      if (verbose) {
        cli::cat_line()
        cli::cat_boxx("Constraints",
          float = "center"
        )
        secretary::typewrite("Executing constraints...")
      }

      constraints(
        conn = conn,
        target_schema = target_schema,
        verbose = verbose,
        render_sql = render_sql
      )
    }

    if ("chariotviz_cache" %in% steps) {

      version_key <-
        chariotViz::get_version_key(conn = conn)

      chariotViz::setup_chariotViz(conn = conn,
                                   schema = target_schema,
                                   verbose = verbose,
                                   render_sql = render_sql,
                                   version_key = version_key)


    }
  }
