#' setupAthenaLog S4 Class

setupAthenaLog <-
        setClass("setupAthenaLog",
                 slots =
                         c("timestamp" = "POSIXct",
                           "schema" = "character",
                           "release_version" = "character",
                           "row_counts" = "list",
                           "vocabulary_versions" = "list"))



vocabulary_tables_lc <-
        c('concept', 'vocabulary', 'domain', 'concept_class', 'concept_relationship', 'relationship', 'concept_synonym', 'concept_ancestor', 'source_to_concept_map', 'drug_strength')

