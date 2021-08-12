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
