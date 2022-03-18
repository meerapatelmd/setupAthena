develop_neo4j_data <-
        function(conn,
                 conn_fun = "pg13::local_connect()",
                 sql_statement,
                 output_folder = "~/Desktop",
                 checks = "",
                 verbose = TRUE,
                 render_sql = TRUE,
                 render_only = FALSE) {


                omop_version <-
                pg13::query(
                        conn = conn,
                        conn_fun = conn_fun,
                        sql_statement =
                        "
                        SELECT sa_release_version
                        FROM public.setup_athena_log
                        WHERE sa_datetime IN (SELECT MAX(sa_datetime) FROM public.setup_athena_log);
                        ",
                        checks = checks,
                        verbose = verbose,
                        render_sql = render_sql) %>%
                        unlist() %>%
                        unname()

                output_dir <-
                        file.path("dev",
                                  "neo4j",
                                  omop_version)

                if (!dir.exists(output_dir)) {

                        dir.create(output_dir)

                }


                final_node_csv <- file.path(output_dir, "node.csv")
                final_edge_csv <- file.path(output_dir, "edge.csv")


                if (!file.exists(final_node_csv)|!file.exists(final_edge_csv)) {


                        sql_path <-
                                file.path("inst",
                                          "sql",
                                          "dev",
                                          "neo4j.sql")



                sql_statement <-
                        readLines(sql_path)

                sql_statement <-
                        paste(sql_statement,
                              collapse = "\n")

                sql_statement <-
                        glue::glue(sql_statement)


                pg13::send(
                        conn = conn,
                        conn_fun = conn_fun,
                        sql_statement = sql_statement,
                        checks = checks,
                        verbose = verbose,
                        render_sql = render_sql
                )

                # command <-
                #         sprintf("cd\ncd %s\nzip -r %s ./*",
                #                 glitter::formatCli(tmp_dir),
                #                 glitter::formatCli(final_zip_file))
                #
                # system(
                #         command = command
                # )

                }


                inst_dir <-
                        path.expand(output_folder)

                if (!dir.exists(inst_dir)) {

                        dir.create(inst_dir)

                }

                zip_file <-
                        file.path(
                                inst_dir,
                                xfun::with_ext(omop_version, "zip")
                        )


                if (!file.exists(zip_file)) {

                command <-
                        sprintf("cd\ncd %s\nzip -r %s ./*",
                                glitter::formatCli(file.path(here::here(),output_dir)),
                                glitter::formatCli(zip_file))

                system(command = command)


                }








        }
