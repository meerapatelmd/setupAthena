library(tidyverse)
library(rlang)
library(R.cache)
conn <- chariot::connectAthena()

indices(conn = conn,
        targetSchema = "public")

chariot::dcAthena(conn = conn,
                  remove = TRUE)
#
#
# # Adding the @schema. prefix to vocabulary table names
# indexesSQL <- SqlRender::readSql(sourceFile = "inst/sql/indexes.sql")
# indexesSQL <- pg13::parseSQL(indexesSQL)
# sourceTables <- paste0("( )(", tolower(setupAthena::vocabularyTableNames), ")( )")
# newIndexesSQL <- vector()
# for (i in 1:length(indexesSQL)) {
#         sql <- indexesSQL[i]
#
#         for (j in 1:length(sourceTables)) {
#                 table <- sourceTables[j]
#
#                 if (j == 1) {
#                         newIndexesSQL[i] <-
#                                 stringr::str_replace_all(sql, pattern = table, replacement = " @schema.\\2\\3")
#                 } else {
#
#                         newIndexesSQL[i]  <-
#                                 stringr::str_replace_all(newIndexesSQL[i], pattern = table, replacement = " @schema.\\2\\3")
#                 }
#
#
#         }
#
# }
# write_lines(newIndexesSQL,
#             path = "inst/sql/indices.sql")
