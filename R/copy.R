#' @title
#' Copy New Vocabulary
#'
#' @description
#' This function copies a freshly downloaded and unpacked
#' vocabulary export from \href{athena.ohdsi.org}{Athena}.
#' If CPT4 is included in the downloaded bundle and has not
#' been reconstituted, please do so following the
#' instructions in the README.txt that is in the unpacked
#' vocabulary download or run \code{\link{prepare_cpt4}}
#' from the R console. Without running this step, CPT4 will
#' not be included in the new Concept table.
#'
#' @seealso
#'  \code{\link[SqlRender]{render}}
#'  \code{\link[pg13]{send}}
#'  \code{\link[secretary]{typewrite}}
#'  \code{\link[purrr]{map}}
#' @rdname copy
#' @export
#' @importFrom SqlRender render
#' @importFrom pg13 send
#' @importFrom secretary typewrite enbold redTxt
#' @importFrom purrr map

copy <-
  function(path_to_csvs,
           target_schema,
           conn,
           verbose = TRUE,
           render_sql = TRUE) {
    vocabulary_files <-
      c(
        "CONCEPT_ANCESTOR.csv",
        "CONCEPT_CLASS.csv",
        "CONCEPT_RELATIONSHIP.csv",
        "CONCEPT_SYNONYM.csv",
        "CONCEPT.csv",
        "DOMAIN.csv",
        "DRUG_STRENGTH.csv",
        "RELATIONSHIP.csv",
        "VOCABULARY.csv"
      )


    table_names <-
      c(
        "CONCEPT_ANCESTOR",
        "CONCEPT_CLASS",
        "CONCEPT_RELATIONSHIP",
        "CONCEPT_SYNONYM",
        "CONCEPT",
        "DOMAIN",
        "DRUG_STRENGTH",
        "RELATIONSHIP",
        "VOCABULARY"
      )

    paths_to_csvs <-
      path.expand(file.path(
        path_to_csvs,
        vocabulary_files
      ))

    errors <- vector()
    for (i in seq_along(paths_to_csvs)) {
      vocabulary_file <- paths_to_csvs[i]
      table_name <- table_names[i]


      sql <- SqlRender::render("COPY @schema.@tableName FROM '@vocabulary_file' WITH
DELIMITER E'\\t' CSV HEADER QUOTE E'\\b';",
        schema = target_schema,
        tableName = table_name,
        vocabulary_file = vocabulary_file
      )

      output <-
        tryCatch(pg13::send(
          conn = conn,
          sql_statement = sql,
          verbose = verbose,
          render_sql = render_sql
        ),
        error = function(e) "Error"
        )

      if ((length(output) == 1) && (output %in% "Error")) {
        errors <-
          c(errors, table_name)
      }
    }

    if (length(errors)) {
      secretary::typewrite(
        secretary::enbold(secretary::redTxt("WARNING:")),
        "The following tables failed to load:"
      )

      errors %>%
        purrr::map(~ secretary::typewrite(.,
          tabs = 4,
          timepunched = FALSE
        ))
    } else {
      secretary::typewrite("All tables copied successfully:")
      table_names %>%
        purrr::map(~ secretary::typewrite(.,
          tabs = 4,
          timepunched = FALSE
        ))
    }
  }
