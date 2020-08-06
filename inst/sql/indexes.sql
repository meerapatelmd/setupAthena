ALTER TABLE concept ADD CONSTRAINT xpk_concept PRIMARY KEY (concept_id);

ALTER TABLE vocabulary ADD CONSTRAINT xpk_vocabulary PRIMARY KEY (vocabulary_id);

ALTER TABLE domain ADD CONSTRAINT xpk_domain PRIMARY KEY (domain_id);

ALTER TABLE concept_class ADD CONSTRAINT xpk_concept_class PRIMARY KEY (concept_class_id);

ALTER TABLE concept_relationship ADD CONSTRAINT xpk_concept_relationship PRIMARY KEY (concept_id_1,concept_id_2,relationship_id);

ALTER TABLE relationship ADD CONSTRAINT xpk_relationship PRIMARY KEY (relationship_id);

ALTER TABLE concept_ancestor ADD CONSTRAINT xpk_concept_ancestor PRIMARY KEY (ancestor_concept_id,descendant_concept_id);

ALTER TABLE source_to_concept_map ADD CONSTRAINT xpk_source_to_concept_map PRIMARY KEY (source_vocabulary_id,target_concept_id,source_code,valid_end_date);

ALTER TABLE drug_strength ADD CONSTRAINT xpk_drug_strength PRIMARY KEY (drug_concept_id, ingredient_concept_id);

CREATE UNIQUE INDEX idx_concept_concept_id  ON concept  (concept_id ASC);
CLUSTER concept  USING idx_concept_concept_id ;
CREATE INDEX idx_concept_code ON concept (concept_code ASC);
CREATE INDEX idx_concept_vocabluary_id ON concept (vocabulary_id ASC);
CREATE INDEX idx_concept_domain_id ON concept (domain_id ASC);
CREATE INDEX idx_concept_class_id ON concept (concept_class_id ASC);
CREATE INDEX idx_concept_id_varchar ON concept (CAST(concept_id AS VARCHAR));

CREATE UNIQUE INDEX idx_vocabulary_vocabulary_id  ON vocabulary  (vocabulary_id ASC);
CLUSTER vocabulary  USING idx_vocabulary_vocabulary_id ;

CREATE UNIQUE INDEX idx_domain_domain_id  ON domain  (domain_id ASC);
CLUSTER domain  USING idx_domain_domain_id ;

CREATE UNIQUE INDEX idx_concept_class_class_id  ON concept_class  (concept_class_id ASC);
CLUSTER concept_class  USING idx_concept_class_class_id ;

CREATE INDEX idx_concept_relationship_id_1 ON concept_relationship (concept_id_1 ASC);
CREATE INDEX idx_concept_relationship_id_2 ON concept_relationship (concept_id_2 ASC);
CREATE INDEX idx_concept_relationship_id_3 ON concept_relationship (relationship_id ASC);

CREATE UNIQUE INDEX idx_relationship_rel_id  ON relationship  (relationship_id ASC);
CLUSTER relationship  USING idx_relationship_rel_id ;

CREATE INDEX idx_concept_synonym_id  ON concept_synonym  (concept_id ASC);
CLUSTER concept_synonym  USING idx_concept_synonym_id ;

CREATE INDEX idx_concept_ancestor_id_1  ON concept_ancestor  (ancestor_concept_id ASC);
CLUSTER concept_ancestor  USING idx_concept_ancestor_id_1 ;
CREATE INDEX idx_concept_ancestor_id_2 ON concept_ancestor (descendant_concept_id ASC);

CREATE INDEX idx_source_to_concept_map_id_3  ON source_to_concept_map  (target_concept_id ASC);
CLUSTER source_to_concept_map  USING idx_source_to_concept_map_id_3 ;
CREATE INDEX idx_source_to_concept_map_id_1 ON source_to_concept_map (source_vocabulary_id ASC);
CREATE INDEX idx_source_to_concept_map_id_2 ON source_to_concept_map (target_vocabulary_id ASC);
CREATE INDEX idx_source_to_concept_map_code ON source_to_concept_map (source_code ASC);

CREATE INDEX idx_drug_strength_id_1  ON drug_strength  (drug_concept_id ASC);
CLUSTER drug_strength  USING idx_drug_strength_id_1 ;
CREATE INDEX idx_drug_strength_id_2 ON drug_strength (ingredient_concept_id ASC);