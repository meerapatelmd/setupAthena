



is_cpt4_reconstituted <-
        function(path_to_csvs) {

                out <-
                "logs" %in%
                        list.dirs(path = path_to_csvs,
                                  full.names = FALSE)

                if (!(out)) {

                        cli::cli_alert_warning(text = "CPT4 has not been reconstituted. Folder `logs` not present.")


                }

                out



        }
