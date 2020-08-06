## code to prepare `load-data` dataset goes here

vocabularyTableNames <- c("ATTRIBUTE_DEFINITION", "CONCEPT", "CONCEPT_ANCESTOR", "CONCEPT_CLASS", "CONCEPT_RELATIONSHIP", "CONCEPT_SYNONYM", "DOMAIN", "DRUG_STRENGTH", "RELATIONSHIP", "SOURCE_TO_CONCEPT_MAP", "VOCABULARY")

usethis::use_data(vocabularyTableNames, overwrite = TRUE)
