#' @title
#' Get the current OMOP Vocabulary version in the Database
#' @rdname get_version
#' @export
#' @importFrom pg13 query
get_version <-
        function(conn,
                 conn_fun = "pg13::local_connect()",
                 verbose = TRUE,
                 render_sql = TRUE,
                 render_only = FALSE,
                 checks = "") {


                pg13::query(
                        conn = conn,
                        conn_fun  = conn_fun,
                        sql_statement =
                "SELECT sa_release_version FROM public.setup_athena_log WHERE sa_datetime IN (SELECT MAX(sa_datetime) FROM public.setup_athena_log);",
                verbose = verbose,
                render_sql = render_sql,
                render_only = render_only,
                checks = checks) %>%
                        unlist() %>%
                        unname()

        }



#' @title
#' Get the most current OMOP Vocabulary release available
#' @param local_repo_path Path to the cloned OHDSI Vocabulary repository, Default: '~/GitHub/OHDSI/Vocabulary-v5.0/'
#' @param cdm_version String that is appended to the beginning of the tag used to determine the version, Default: 'V5.0'
#' @rdname get_github_release
#' @export
#' @importFrom glitter list_tags
#' @importFrom stringr str_replace
#' @importFrom lubridate ymd
get_github_release <-
        function(local_repo_path = "~/GitHub/OHDSI/Vocabulary-v5.0/",
                         cdm_version = "V5.0") {

                x <-
                        names(glitter::list_tags(path = local_repo_path))
                ## Ordered in descending order by date
                ## [1] "v20210902_1630584693",....

                x <-
                        grep(pattern = "v.*?_[0-9]{1,}$",
                             x = x,
                             value = TRUE)


                x <- x[1]
                ## [1] "v20210902_1630584693"


                x <- stringr::str_replace(
                        string = x,
                        pattern = "v(.*?)_.*$",
                        replacement = "\\1"
                )
                ## [1] "20210902"

                x <- lubridate::ymd(x)
                ## [1] "2021-09-02"

                x <- format(x,
                            "%d-%b-%g")
                ## [1] "02-Sep-21"

                x <- toupper(as.character(x))
                ## [1] "02-SEP-21"

                x <- sprintf("%s %s",
                             cdm_version,
                             x)
                ## [1] "v5.0 02-SEP-21"

                toupper(x)

        }
