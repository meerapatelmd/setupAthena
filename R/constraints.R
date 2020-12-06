#' Execute Athena Constraints
#' @description
#' The constraints are performed using the SQL found at \href{https://raw.githubusercontent.com/OHDSI/CommonDataModel/master/PostgreSQL/OMOP%20CDM%20postgresql%20constraints.txt}{OHDSI OMOP CDM Postgresl Constraints}
#' @seealso
#'  \code{\link[SqlRender]{render}},\code{\link[SqlRender]{readSql}}
#'  \code{\link[pg13]{sourceFilePath}},\code{\link[pg13]{parseSQL}},\code{\link[pg13]{sendList}}
#' @rdname constraints
#' @export
#' @importFrom SqlRender render readSql
#' @importFrom pg13 sourceFilePath parseSQL sendList

constraints <-
    function(conn,
             target_schema,
             verbose = TRUE,
             render_sql = TRUE) {


            sql <- SqlRender::render(
                "
                ALTER TABLE @schema.concept ADD CONSTRAINT fpk_concept_domain FOREIGN KEY (domain_id)  REFERENCES domain (domain_id);
                ALTER TABLE @schema.concept ADD CONSTRAINT fpk_concept_class FOREIGN KEY (concept_class_id)  REFERENCES concept_class (concept_class_id);
                ALTER TABLE @schema.concept ADD CONSTRAINT fpk_concept_vocabulary FOREIGN KEY (vocabulary_id)  REFERENCES vocabulary (vocabulary_id);
                ALTER TABLE @schema.vocabulary ADD CONSTRAINT fpk_vocabulary_concept FOREIGN KEY (vocabulary_concept_id)  REFERENCES concept (concept_id);
                ALTER TABLE @schema.domain ADD CONSTRAINT fpk_domain_concept FOREIGN KEY (domain_concept_id)  REFERENCES concept (concept_id);
                ALTER TABLE @schema.concept_class ADD CONSTRAINT fpk_concept_class_concept FOREIGN KEY (concept_class_concept_id)  REFERENCES concept (concept_id);
                ALTER TABLE @schema.concept_relationship ADD CONSTRAINT fpk_concept_relationship_c_1 FOREIGN KEY (concept_id_1)  REFERENCES concept (concept_id);
                ALTER TABLE @schema.concept_relationship ADD CONSTRAINT fpk_concept_relationship_c_2 FOREIGN KEY (concept_id_2)  REFERENCES concept (concept_id);
                ALTER TABLE @schema.concept_relationship ADD CONSTRAINT fpk_concept_relationship_id FOREIGN KEY (relationship_id)  REFERENCES relationship (relationship_id);
                ALTER TABLE @schema.relationship ADD CONSTRAINT fpk_relationship_concept FOREIGN KEY (relationship_concept_id)  REFERENCES concept (concept_id);
                ALTER TABLE @schema.relationship ADD CONSTRAINT fpk_relationship_reverse FOREIGN KEY (reverse_relationship_id)  REFERENCES relationship (relationship_id);
                ALTER TABLE @schema.concept_synonym ADD CONSTRAINT fpk_concept_synonym_concept FOREIGN KEY (concept_id)  REFERENCES concept (concept_id);
                ALTER TABLE @schema.concept_synonym ADD CONSTRAINT fpk_concept_synonym_language_concept FOREIGN KEY (language_concept_id)  REFERENCES concept (concept_id);
                ALTER TABLE @schema.concept_ancestor ADD CONSTRAINT fpk_concept_ancestor_concept_1 FOREIGN KEY (ancestor_concept_id)  REFERENCES concept (concept_id);
                ALTER TABLE @schema.concept_ancestor ADD CONSTRAINT fpk_concept_ancestor_concept_2 FOREIGN KEY (descendant_concept_id)  REFERENCES concept (concept_id);
                ALTER TABLE @schema.source_to_concept_map ADD CONSTRAINT fpk_source_to_concept_map_v_1 FOREIGN KEY (source_vocabulary_id)  REFERENCES vocabulary (vocabulary_id);
                ALTER TABLE @schema.source_to_concept_map ADD CONSTRAINT fpk_source_to_concept_map_v_2 FOREIGN KEY (target_vocabulary_id)  REFERENCES vocabulary (vocabulary_id);
                ALTER TABLE @schema.source_to_concept_map ADD CONSTRAINT fpk_source_to_concept_map_c_1 FOREIGN KEY (target_concept_id)  REFERENCES concept (concept_id);
                ALTER TABLE @schema.drug_strength ADD CONSTRAINT fpk_drug_strength_concept_1 FOREIGN KEY (drug_concept_id)  REFERENCES concept (concept_id);
                ALTER TABLE @schema.drug_strength ADD CONSTRAINT fpk_drug_strength_concept_2 FOREIGN KEY (ingredient_concept_id)  REFERENCES concept (concept_id);
                ALTER TABLE @schema.drug_strength ADD CONSTRAINT fpk_drug_strength_unit_1 FOREIGN KEY (amount_unit_concept_id)  REFERENCES concept (concept_id);
                ALTER TABLE @schema.drug_strength ADD CONSTRAINT fpk_drug_strength_unit_2 FOREIGN KEY (numerator_unit_concept_id)  REFERENCES concept (concept_id);
                ALTER TABLE @schema.drug_strength ADD CONSTRAINT fpk_drug_strength_unit_3 FOREIGN KEY (denominator_unit_concept_id)  REFERENCES concept (concept_id);
                ALTER TABLE @schema.concept_synonym ADD CONSTRAINT uq_concept_synonym UNIQUE (concept_id, concept_synonym_name, language_concept_id);
                ALTER TABLE @schema.concept ADD CONSTRAINT chk_c_concept_name CHECK (concept_name <> '');
                ALTER TABLE @schema.concept ADD CONSTRAINT chk_c_standard_concept CHECK (COALESCE(standard_concept,'C') in ('C','S'));
                ALTER TABLE @schema.concept ADD CONSTRAINT chk_c_concept_code CHECK (concept_code <> '');
                ALTER TABLE @schema.concept ADD CONSTRAINT chk_c_invalid_reason CHECK (COALESCE(invalid_reason,'D') in ('D','U'));
                ALTER TABLE @schema.concept_relationship ADD CONSTRAINT chk_cr_invalid_reason CHECK (COALESCE(invalid_reason,'D')='D');
                ALTER TABLE @schema.concept_synonym ADD CONSTRAINT chk_csyn_concept_synonym_name CHECK (concept_synonym_name <> '');
                ",
                schema = targetSchema)


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

