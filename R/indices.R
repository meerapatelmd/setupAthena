#' @title
#' Execute Athena Indexes
#' @description
#' SQL for indices derived from \url{"https://raw.githubusercontent.com/OHDSI/CommonDataModel/master/PostgreSQL/OMOP%20CDM%20postgresql%20pk%20indexes.txt"}
#' @seealso
#'  \code{\link[SqlRender]{render}}
#'  \code{\link[pg13]{execute_n}}
#' @rdname indices
#' @export
#' @importFrom SqlRender render
#' @importFrom pg13 execute_n

indices <-
    function(conn,
             target_schema,
             verbose = TRUE,
             render_sql = TRUE) {


        sql <-
            SqlRender::render(
        "
        ALTER TABLE @schema.concept ADD CONSTRAINT xpk_concept PRIMARY KEY (concept_id);
        ALTER TABLE @schema.vocabulary ADD CONSTRAINT xpk_vocabulary PRIMARY KEY (vocabulary_id);
        ALTER TABLE @schema.domain ADD CONSTRAINT xpk_domain PRIMARY KEY (domain_id);
        ALTER TABLE @schema.concept_class ADD CONSTRAINT xpk_concept_class PRIMARY KEY (concept_class_id);
        ALTER TABLE @schema.concept_relationship ADD CONSTRAINT xpk_concept_relationship PRIMARY KEY (concept_id_1,concept_id_2,relationship_id);
        ALTER TABLE @schema.relationship ADD CONSTRAINT xpk_relationship PRIMARY KEY (relationship_id);
        ALTER TABLE @schema.concept_ancestor ADD CONSTRAINT xpk_concept_ancestor PRIMARY KEY (ancestor_concept_id,descendant_concept_id);
        ALTER TABLE @schema.source_to_concept_map ADD CONSTRAINT xpk_source_to_concept_map PRIMARY KEY (source_vocabulary_id,target_concept_id,source_code,valid_end_date);
        ALTER TABLE @schema.drug_strength ADD CONSTRAINT xpk_drug_strength PRIMARY KEY (drug_concept_id, ingredient_concept_id);
        CREATE UNIQUE INDEX idx_concept_concept_id ON @schema.concept (concept_id ASC);
        CLUSTER @schema.concept USING idx_concept_concept_id ;
        CREATE INDEX idx_concept_code ON @schema.concept (concept_code ASC);
        CREATE INDEX idx_concept_vocabluary_id ON @schema.concept (vocabulary_id ASC);
        CREATE INDEX idx_concept_domain_id ON @schema.concept (domain_id ASC);
        CREATE INDEX idx_concept_class_id ON @schema.concept (concept_class_id ASC);
        CREATE INDEX idx_concept_id_varchar ON @schema.concept (CAST(concept_id AS VARCHAR));
        CREATE UNIQUE INDEX idx_vocabulary_vocabulary_id ON @schema.vocabulary (vocabulary_id ASC);
        CLUSTER @schema.vocabulary USING idx_vocabulary_vocabulary_id ;
        CREATE UNIQUE INDEX idx_domain_domain_id ON @schema.domain (domain_id ASC);
        CLUSTER @schema.domain USING idx_domain_domain_id ;
        CREATE UNIQUE INDEX idx_concept_class_class_id ON @schema.concept_class (concept_class_id ASC);
        CLUSTER @schema.concept_class USING idx_concept_class_class_id ;
        CREATE INDEX idx_concept_relationship_id_1 ON @schema.concept_relationship (concept_id_1 ASC);
        CREATE INDEX idx_concept_relationship_id_2 ON @schema.concept_relationship (concept_id_2 ASC);
        CREATE INDEX idx_concept_relationship_id_3 ON @schema.concept_relationship (relationship_id ASC);
        CREATE UNIQUE INDEX idx_relationship_rel_id ON @schema.relationship (relationship_id ASC);
        CLUSTER @schema.relationship USING idx_relationship_rel_id ;
        CREATE INDEX idx_concept_synonym_id ON @schema.concept_synonym (concept_id ASC);
        CLUSTER @schema.concept_synonym USING idx_concept_synonym_id ;
        CREATE INDEX idx_concept_ancestor_id_1 ON @schema.concept_ancestor (ancestor_concept_id ASC);
        CLUSTER @schema.concept_ancestor USING idx_concept_ancestor_id_1 ;
        CREATE INDEX idx_concept_ancestor_id_2 ON @schema.concept_ancestor (descendant_concept_id ASC);
        CREATE INDEX idx_source_to_concept_map_id_3 ON @schema.source_to_concept_map (target_concept_id ASC);
        CLUSTER @schema.source_to_concept_map USING idx_source_to_concept_map_id_3 ;
        CREATE INDEX idx_source_to_concept_map_id_1 ON @schema.source_to_concept_map (source_vocabulary_id ASC);
        CREATE INDEX idx_source_to_concept_map_id_2 ON @schema.source_to_concept_map (target_vocabulary_id ASC);
        CREATE INDEX idx_source_to_concept_map_code ON @schema.source_to_concept_map (source_code ASC);
        CREATE INDEX idx_drug_strength_id_1 ON @schema.drug_strength (drug_concept_id ASC);
        CLUSTER @schema.drug_strength USING idx_drug_strength_id_1 ;
        CREATE INDEX idx_drug_strength_id_2 ON @schema.drug_strength (ingredient_concept_id ASC);
        ", schema = target_schema)


        sql_statements <-
            strsplit(x = sql,
                     split = ";") %>%
            unlist() %>%
            trimws(which = "both")


        pg13::execute_n(conn = conn,
                      sql_statements = sql_statements,
                      verbose = verbose,
                      render_sql = verbose)


    }

