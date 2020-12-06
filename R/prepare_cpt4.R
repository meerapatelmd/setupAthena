#' @title
#' Reconstitute CPT4 Concepts
#' @description
#' Run the java script that reconstitutes CPT4 concepts directly from the R console.
#'
#' @inheritParams pkg_args
#' @return OUTPUT_DESCRIPTION
#' @details DETAILS
#' @examples
#' \dontrun{
#' if(interactive()){
#'  #EXAMPLE1
#'  }
#' }
#' @seealso
#'  \code{\link[cli]{cat_line}}
#'  \code{\link[secretary]{c("typewrite", "typewrite")}},\code{\link[secretary]{character(0)}}
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


                        cli::cat_boxx("Reconstitute CPT4")

                        command <- list()
                        command[[1]] <- sprintf("cd")
                        command[[2]] <- sprintf("cd %s",
                                                path.expand(path_to_csvs))
                        command[[3]] <- sprintf("java -Dumls-apikey=%s -jar cpt4.jar 5",
                                                umls_api_key)

                        if (verbose) {
                                secretary::typewrite(secretary::magentaTxt("Command:"))
                                command %>%
                                        purrr::map(~  secretary::typewrite(.,
                                                                           tabs = 4, timepunched = FALSE))
                                cli::cat_line()
                        }


                        command <-
                                command %>%
                                unlist() %>%
                                paste(collapse = "\n")

                        system(command = command)

                        cli::cat_line()

        }
