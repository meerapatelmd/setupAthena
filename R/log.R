#' @title
#' Log Update
#'
#' @description
#' This function prints the number of rows for all the
#' vocabulary tables in the R console.
#'
#' @rdname log
#' @export
#' @importFrom purrr map set_names
#' @importFrom pg13 query renderRowCount read_table table_exists rename_table write_table drop_table
#' @importFrom dplyr bind_rows rename mutate select everything rename_all
#' @importFrom SqlRender render
#' @importFrom cli cat_line cat_boxx
#' @importFrom tidyr pivot_wider
#' @importFrom stringr str_replace_all
#' @import huxtable

log <-
  function(conn,
           target_schema,
           verbose = TRUE,
           render_sql = TRUE,
           release_version) {

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

    current_row_count <-
      table_names %>%
      purrr::map(function(x) {
        pg13::query(
          conn = conn,
          sql_statement = pg13::renderRowCount(
            schema = target_schema,
            tableName = x
          )
        )
      }) %>%
      purrr::set_names(table_names) %>%
      dplyr::bind_rows(.id = "Table") %>%
      dplyr::rename(Rows = count)


    vocabulary_ids <-
      pg13::query(
        conn = conn,
        sql_statement = SqlRender::render(
        "WITH c AS (
           SELECT DISTINCT vocabulary_id
           FROM @schema.CONCEPT
          )

         SELECT v.*
         FROM @schema.VOCABULARY v
         INNER JOIN c
         ON v.vocabulary_id = c.vocabulary_id
         ORDER BY v.vocabulary_id;",
          schema = target_schema
        )
      )


    cli::cat_line()
    cli::cat_boxx("Log Results",
      float = "center"
    )

    cli::cat_line()

    new_log_entry <-
      tibble::tibble(sa_datetime = Sys.time()) %>%
      dplyr::mutate(sa_release_version = release_version) %>%
      dplyr::mutate(sa_schema = target_schema)


    current_row_count <-
      current_row_count %>%
      tidyr::pivot_wider(
        names_from = "Table",
        values_from = "Rows"
      ) %>%
      dplyr::rename_all(~tolower(paste0(.,"_rows")))

    vocabulary_versions <-
      pg13::read_table(
        conn = conn,
        schema = target_schema,
        table = "vocabulary",
        verbose = verbose,
        render_sql = render_sql
      ) %>%
      dplyr::select(
        vocabulary_id,
        vocabulary_version
      ) %>%
      tidyr::pivot_wider(
        names_from = vocabulary_id,
        names_glue = "{vocabulary_id} Version",
        values_from = vocabulary_version
      )

    vocabulary_cts <-
    pg13::query(
      conn = conn,
      sql_statement = SqlRender::render(
        "
        WITH all_vocabs AS (
          SELECT vocabulary_id
          FROM @schema.VOCABULARY v
        ),
        cts AS (
          SELECT vocabulary_id,COUNT(DISTINCT concept_id) AS vocabulary_id_ct
          FROM @schema.CONCEPT c
          GROUP BY vocabulary_id
          ORDER BY COUNT(DISTINCT concept_id)
        )

        SELECT
          all_vocabs.vocabulary_id,
          CASE WHEN cts.vocabulary_id_ct IS NULL THEN 0 ELSE cts.vocabulary_id_ct
            END vocabulary_id_ct
        FROM all_vocabs
        LEFT JOIN cts
        ON all_vocabs.vocabulary_id = cts.vocabulary_id
        ",
        schema = target_schema
      )
    )

    vocabulary_cts2 <-
      vocabulary_cts %>%
      dplyr::filter(vocabulary_id_ct != 0) %>%
      tidyr::pivot_wider(
        names_from = vocabulary_id,
        names_glue = "{vocabulary_id}_ct",
        values_from = vocabulary_id_ct
      )

    new_log_entry2 <-
      cbind(
        vocabulary_versions,
        vocabulary_cts2
      ) %>%
      dplyr::rename_all(tolower) %>%
      dplyr::rename_all(
        stringr::str_replace_all,
        "[ ]|[+]",
        "_"
      )
    new_log_entry2 <-
    new_log_entry2 %>%
      dplyr::select(dplyr::all_of(sort(colnames(new_log_entry2))))

    final_log_entry <-
      cbind(
        new_log_entry,
        current_row_count,
        new_log_entry2
      )


    if (pg13::table_exists(
      conn = conn,
      schema = "public",
      table_name = "setup_athena_log"
    )) {


      old_log <-
        pg13::read_table(
          conn = conn,
          schema = "public",
          table = "setup_athena_log",
          verbose = verbose,
          render_sql = render_sql
        )

      old_field_names <-
      c(
        'concept_ancestor',
        'concept_class',
        'concept_relationship',
        'concept_synonym',
        'concept',
        'domain',
        'drug_strength',
        'relationship',
        'vocabulary'
      )

      old_log <-
        old_log %>%
        dplyr::rename_at(dplyr::vars(dplyr::any_of(old_field_names)),
                         ~paste0(., "_rows"))


      new_log <-
        dplyr::bind_rows(
          old_log,
          final_log_entry) %>%
        dplyr::select(dplyr::all_of(colnames(final_log_entry)))


      pg13::rename_table(
        conn = conn,
        schema = "public",
        tableName = "setup_athena_log",
        newTableName = "previous_setup_athena_log",
        verbose = verbose,
        render_sql = render_sql
      )

      on.exit(expr =
                pg13::rename_table(
                  conn = conn,
                  schema = "public",
                  tableName = "previous_setup_athena_log",
                  newTableName = "setup_athena_log",
                  verbose = verbose,
                  render_sql = render_sql
                )
                )
    } else {
      new_log <- final_log_entry
    }


    pg13::write_table(
      conn = conn,
      schema = "public",
      table = "setup_athena_log",
      data = new_log,
      verbose = verbose,
      render_sql = render_sql
    )


    on.exit(expr =
              pg13::drop_table(
                conn = conn,
                schema = "public",
                table = "previous_setup_athena_log",
                verbose = verbose,
                render_sql = render_sql,
                if_exists = TRUE
              )
    )

    empty_vocabularies <-
      vocabulary_cts %>%
      dplyr::filter(vocabulary_id_ct == 0)

    if (nrow(empty_vocabularies)>0) {

      report_empties <-
        function() {
      secretary::typewrite_warning("The following vocabularies do not have concepts:")
      sapply(empty_vocabularies$vocabulary_id,
             FUN = secretary::typewrite,
             timepunched = FALSE,
             tabs = 5)
        }

      on.exit(report_empties(),
              add = TRUE,
              after = TRUE)


    }

    updated_log <-
      pg13::read_table(
        conn = conn,
        schema = "public",
        table = "setup_athena_log",
        verbose = verbose,
        render_sql = render_sql
      )

    last_row <-
      updated_log %>%
      dplyr::mutate_all(as.character) %>%
      dplyr::filter(dplyr::row_number() == nrow(updated_log)) %>%
      tidyr::pivot_longer(cols = dplyr::everything())

    second_to_last_row <-
      updated_log %>%
      dplyr::mutate_all(as.character) %>%
      dplyr::filter(dplyr::row_number() == (nrow(updated_log)-1))  %>%
      tidyr::pivot_longer(cols = dplyr::everything())


    comparison_hx <-
    second_to_last_row %>%
      dplyr::full_join(last_row,
                       by = "name",
                       suffix = c("_before", "_after")) %>%
      dplyr::mutate(diff_exists =
               value_before != value_after) %>%
      dplyr::filter(diff_exists == TRUE) %>%
      dplyr::select(-diff_exists) %>%
      huxtable::hux() %>%
      huxtable::theme_article()

    on.exit(
      huxtable::print_screen(ht = comparison_hx,
                             colnames = FALSE),
            add = TRUE,
            after = TRUE)


  }
