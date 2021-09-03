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
           umls_api_key,
           verbose = TRUE) {

    stopifnot(length(umls_api_key)==1)
    stopifnot(umls_api_key!="")


    concept_path <-
      file.path(path_to_csvs, "CONCEPT.csv")
    concept_without_cpt4_path <-
      file.path(path_to_csvs, "CONCEPT_WITHOUT_CPT4.csv")
    log_dir <-
      file.path(path_to_csvs, "logs")

    replace_incomplete_concept <-
      function(concept_path,
               concept_without_cpt4_path,
               log_dir) {

        file.remove(concept_path)
        file.rename(from = concept_without_cpt4_path,
                    to = concept_path)
        if (dir.exists(log_dir)) {

          unlink(log_dir,
                 recursive = TRUE)

        }

      }

    if (!file.exists(concept_without_cpt4_path)) {

      file.copy(from = concept_path,
                to   = concept_without_cpt4_path)

    }

    on.exit(replace_incomplete_concept(concept_path = concept_path,
                                       concept_without_cpt4_path = concept_without_cpt4_path,
                                       log_dir = log_dir))

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

    on.exit(file.remove(concept_without_cpt4_path))

    command <-
      command %>%
      unlist() %>%
      paste(collapse = "\n")

    system(command = command)

    cli::cat_line()
  }
