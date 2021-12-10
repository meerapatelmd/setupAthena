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
#' @details
#' A copy of the CONCEPT.csv file is made to CONCEPT_WITHOUT_CPT4.csv
#' for safekeeping. If the function exits early, the CONCEPT.csv file
#' is replaced with CONCEPT_WITHOUT_CPT4.csv and the `logs` directory
#' is unlinked recursively. If the function completes, the
#' CONCEPT_WITHOUT_CPT4.csv is removed instead. This way, the file
#' would not need to be redownloaded in case something goes wrong
#' during processing.
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
           umls_api_key = Sys.getenv("UMLS_API_KEY"),
           verbose = TRUE) {

    stopifnot(length(umls_api_key)==1)
    stopifnot(umls_api_key!="")

    cli::cat_boxx("Reconstitute CPT4",
      float = "center"
    )

    command <- list()
    command[[1]] <- sprintf("cd")
    command[[2]] <- sprintf(
      "cd %s",
      path.expand(path_to_csvs)
    )
    command[[3]] <-  "chmod +x cpt.sh"
    command[[4]] <-  sprintf("./cpt.sh %s", umls_api_key)


    if (verbose) {
      secretary::typewrite(secretary::magentaTxt("Command:"))
      command[1:3] %>%
        purrr::map(~ secretary::typewrite(.,
          tabs = 4, timepunched = FALSE
        ))
      secretary::typewrite(
        "./cpt.sh",
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
