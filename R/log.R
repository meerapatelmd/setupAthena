#' @title
#' Log Update
#'
#' @description
#' This function prints the number of rows for all the
#' vocabulary tables in the R console.
#'
#' @rdname log
#' @export
#' @import purrr
#' @import pg13
#' @import dplyr
#' @importFrom cli cat_line cat_boxx
#' @import tibble
#' @import tidyr

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
      current_row_count %>%
      tidyr::pivot_wider(
        names_from = "Table",
        values_from = "Rows"
      ) %>%
      dplyr::mutate(sa_datetime = Sys.time()) %>%
      dplyr::mutate(sa_release_version = release_version) %>%
      dplyr::mutate(sa_schema = target_schema) %>%
      dplyr::select(
        sa_datetime,
        sa_release_version,
        sa_schema,
        dplyr::everything()
      )

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


    new_log_entry <-
      cbind(
        new_log_entry,
        vocabulary_versions
      ) %>%
      dplyr::rename_all(tolower) %>%
      dplyr::rename_all(
        stringr::str_replace_all,
        "[ ]|[+]",
        "_"
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


      new_log <-
        dplyr::bind_rows(
          old_log,
          new_log_entry
        )


      pg13::rename_table(
        conn = conn,
        schema = "public",
        tableName = "setup_athena_log",
        newTableName = "previous_setup_athena_log",
        verbose = verbose,
        render_sql = render_sql
      )
    } else {
      new_log <- new_log_entry
    }


    pg13::write_table(
      conn = conn,
      schema = "public",
      table = "setup_athena_log",
      data = new_log,
      verbose = verbose,
      render_sql = render_sql
    )


    pg13::drop_table(
      conn = conn,
      schema = "public",
      table = "previous_setup_athena_log",
      verbose = verbose,
      render_sql = render_sql
    )
  }
