







prepare_cpt4 <-
        function(path_to_csvs,
                 umls_api_key,
                 verbose = TRUE,
                 render_sql = TRUE) {

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
                        }


                        command <-
                                command %>%
                                unlist() %>%
                                paste(collapse = "\n")

                        system(command = command)

        }
