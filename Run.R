conn <- chariot::connectAthena()

# Drop current schema
setupAthena::clearSchema(conn = conn,
            targetSchema = "public",
            cascade = TRUE)

pg13::send(conn = conn,
           pg13::renderCreateSchema(schema = "public"))

setupAthena::ddl(conn = conn,
                 targetSchema = "public")

# Time: 5 minutes
copyVocabularies(vocabularyPath = "~/Desktop/athena",
                 targetSchema = "public",
                              cpt4 = TRUE,
                 conn = conn)

chariot::dcAthena(conn = conn,
                  remove = TRUE)
