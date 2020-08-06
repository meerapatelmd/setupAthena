# conn <- chariot::connectAthena()
#
# # Drop current schema
# setupAthena::clearSchema(conn = conn,
#             targetSchema = "public",
#             cascade = TRUE)
#
# pg13::send(conn = conn,
#            pg13::renderCreateSchema(schema = "public"))
#
# setupAthena::ddl(conn = conn,
#                  targetSchema = "public")
#
# copyVocabularies(vocabularyPath = "~/Desktop/athena",
#                               cpt4 = TRUE)
#
# chariot::dcAthena(conn = conn,
#                   remove = TRUE)
