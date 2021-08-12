#' @title FUNCTION_TITLE
#' @description FUNCTION_DESCRIPTION
#' @param conn PARAM_DESCRIPTION
#' @param conn_fun PARAM_DESCRIPTION
#' @return OUTPUT_DESCRIPTION
#' @details DETAILS
#' @rdname fetch_last_log
#' @export
#' @importFrom rlang parse_expr
#' @importFrom pg13 dc query
fetch_last_log <-
        function(conn,
                 conn_fun) {


                # Checking Connection
                if (!missing(conn_fun)) {

                        conn <- eval(rlang::parse_expr(conn_fun))
                        on.exit(pg13::dc(conn = conn,
                                         verbose = verbose),
                                add = TRUE,
                                after = TRUE)

                }


                pg13::query(
                        conn = conn,
                        checks = "",
                        sql_statement =
                                "SELECT * FROM public.setup_athena_log WHERE sa_datetime IN (SELECT MAX(sa_datetime) FROM public.setup_athena_log);") %>%
                        as.list()


        }



#' @title FUNCTION_TITLE
#' @description FUNCTION_DESCRIPTION
#' @param conn PARAM_DESCRIPTION
#' @param conn_fun PARAM_DESCRIPTION
#' @return OUTPUT_DESCRIPTION
#' @details DETAILS
#' @rdname fetch_omop_release_version
#' @export
#' @importFrom rlang parse_expr
#' @importFrom pg13 dc
fetch_omop_release_version <-
        function(conn,
                 conn_fun) {


                # Checking Connection
                if (!missing(conn_fun)) {

                        conn <- eval(rlang::parse_expr(conn_fun))
                        on.exit(pg13::dc(conn = conn,
                                         verbose = verbose),
                                add = TRUE,
                                after = TRUE)

                }


                fetch_last_log(conn = conn)$sa_release_version

        }



#' @title FUNCTION_TITLE
#' @description FUNCTION_DESCRIPTION
#' @param vocabulary_id PARAM_DESCRIPTION
#' @param conn PARAM_DESCRIPTION
#' @param conn_fun PARAM_DESCRIPTION
#' @return OUTPUT_DESCRIPTION
#' @details DETAILS
#' @rdname fetch_vocabulary_id_version
#' @export
#' @importFrom rlang parse_expr
#' @importFrom pg13 dc
#' @importFrom stringr str_replace_all
#' @importFrom glue glue
fetch_vocabulary_id_version <-
        function(vocabulary_id,
                 conn,
                 conn_fun) {


                # Checking Connection
                if (!missing(conn_fun)) {

                        conn <- eval(rlang::parse_expr(conn_fun))
                        on.exit(pg13::dc(conn = conn,
                                         verbose = verbose),
                                add = TRUE,
                                after = TRUE)

                }

                vocabulary_id <-
                        tolower(
                                stringr::str_replace_all(string = vocabulary_id,
                                                         pattern = "[ ]|[+]",
                                                         replacement = "_"))

                vocabulary_id_version <- glue::glue("{vocabulary_id}_version")

                fetch_last_log(conn = conn)[[vocabulary_id_version]]

        }
