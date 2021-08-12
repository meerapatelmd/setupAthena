#' @title
#' Reconstitute CPT4 Concepts
#'
#' @description
#' Run the java script that reconstitutes CPT4 concepts
#' directly from the R console. CPT4 will not be loaded
#' into Postgres If this is not run beforehand.
#'
#'
#' @inheritParams pkg_args
#' @param umls_api_key API Key given at
#' \href{https://uts.nlm.nih.gov/uts/profile}{UMLS Licensee Profile}.
#'
#'
#' @seealso
#'  \code{\link[cli]{cat_line}}
#'  \code{\link[secretary]{typewrite}},
#'  \code{\link[purrr]{map}}
#' @rdname prepare_cpt4
#' @export
#' @importFrom cli cat_boxx cat_line
#' @importFrom secretary typewrite magentaTxt
#' @importFrom purrr map


prepare_cpt4 <-
  function(path_to_csvs,
           umls_api_key,
           verbose = TRUE) {
    cli::cat_boxx("Reconstitute CPT4",
      float = "center"
    )

    command <- list()
    command[[1]] <- sprintf("cd")
    command[[2]] <- sprintf(
      "cd %s",
      path.expand(path_to_csvs)
    )
    command[[3]] <- sprintf(
      "java -Dumls-apikey=%s -jar cpt4.jar 5",
      umls_api_key
    )

    if (verbose) {
      secretary::typewrite(secretary::magentaTxt("Command:"))
      command[1:2] %>%
        purrr::map(~ secretary::typewrite(.,
          tabs = 4, timepunched = FALSE
        ))
      secretary::typewrite(
        "java -Dumls-apikey=umls_api_key -jar cpt4.jar 5",
        tabs = 4,
        timepunched = FALSE
      )
      cli::cat_line()
    }


    command <-
      command %>%
      unlist() %>%
      paste(collapse = "\n")

    system(command = command)

    cli::cat_line()
  }
