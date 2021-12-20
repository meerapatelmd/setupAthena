CREATE TABLE IF NOT EXISTS public.process_omop_neo4j_log (

    process_start_datetime timestamp without time zone,

    process_stop_datetime timestamp without time zone,

    omop_version character varying(255),

    target_table character varying(255),

    target_row_ct numeric

);



CREATE OR REPLACE FUNCTION get_omop_neo4j_sql(label_col varchar, id_col varchar, name_col varchar)
RETURNS varchar
AS '
library(glue)

sql_template <-
"
CREATE SCHEMA IF NOT EXISTS omop_neo4j;
DROP TABLE IF EXISTS omop_neo4j.edge;
CREATE TABLE omop_neo4j.edge (
      concept_id_1			        INTEGER			  NOT NULL,
      concept_id_2			        INTEGER			  NOT NULL,
      relationship_id		        VARCHAR(20)	  NOT NULL,
      valid_start_date	        DATE			    NOT NULL,
      valid_end_date		        DATE			    NOT NULL,
      invalid_reason		        VARCHAR(1)		NULL,
 	    relationship_name		      VARCHAR(255)	NOT NULL,
 	    is_hierarchical		        VARCHAR(1)		NOT NULL,
      reverse_relationship_id	  VARCHAR(20)	  NOT NULL,
      reverse_relationship_name VARCHAR(255)  NOT NULL
);

INSERT INTO omop_neo4j.edge
SELECT
	cr.*,
	r.relationship_name,
	r.is_hierarchical,
	r.reverse_relationship_id,
	rr.relationship_name AS reverse_relationship_name
FROM omop_vocabulary.concept_relationship cr
LEFT JOIN omop_vocabulary.relationship r
ON cr.relationship_id = r.relationship_id
LEFT JOIN omop_vocabulary.relationship rr
ON r.reverse_relationship_id = rr.relationship_id
;

DROP TABLE IF EXISTS omop_neo4j.node;
CREATE TABLE omop_neo4j.node AS (
SELECT
  c.concept_id,
  c.concept_name,
  c.domain_id,
  c.vocabulary_id,
  c.concept_class_id,
  c.standard_concept,
  c.concept_code,
  c.valid_start_date,
  c.valid_end_date,
  c.invalid_reason,
  STRING_AGG(cs.concept_synonym_name, ''|'') AS concept_synonyms,
  v.vocabulary_name,
  v.vocabulary_reference,
  v.vocabulary_version
FROM omop_vocabulary.CONCEPT c
LEFT JOIN omop_vocabulary.CONCEPT_SYNONYM cs
ON c.concept_id = cs.concept_id
LEFT JOIN omop_vocabulary.vocabulary v
ON v.vocabulary_id = c.vocabulary_id
WHERE
 cs.language_concept_id = 4180186
GROUP BY
  c.concept_id,
  c.concept_name,
  c.domain_id,
  c.vocabulary_id,
  c.concept_class_id,
  c.standard_concept,
  c.concept_code,
  c.valid_start_date,
  c.valid_end_date,
  c.invalid_reason,
  v.vocabulary_name,
  v.vocabulary_reference,
  v.vocabulary_version
)
;


DROP TABLE IF EXISTS omop_neo4j.pre_edge_header;
CREATE TABLE omop_neo4j.pre_edge_header AS (
SELECT
  concept_id_1    AS start_id_col,
  concept_id_2    AS end_id_col,
  relationship_id AS type_col,
  e.*
FROM omop_neo4j.edge e
LIMIT 5
);

DROP TABLE IF EXISTS omop_neo4j.pre_edge;
CREATE TABLE omop_neo4j.pre_edge AS (
SELECT
  concept_id_1    AS start_id_col,
  concept_id_2    AS end_id_col,
  relationship_id AS type_col,
  e.*
FROM omop_neo4j.edge e
);


DROP TABLE IF EXISTS omop_neo4j.pre_node_header;
CREATE TABLE omop_neo4j.pre_node_header AS (
  SELECT
    <<label_col>> AS label_col,
    <<id_col>>    AS id_col,
    <<name_col>>  AS name_col,
    n.*
  FROM omop_neo4j.node n
  LIMIT 5
);

DROP TABLE IF EXISTS omop_neo4j.pre_node;
CREATE TABLE omop_neo4j.pre_node AS (
  SELECT
    <<label_col>> AS label_col,
    <<id_col>>    AS id_col,
    <<name_col>>  AS name_col,
    n.*
  FROM omop_neo4j.node n
);
"

glue(sql_template, .open = ''<<'', .close = ''>>'')
' LANGUAGE plr;

CREATE OR REPLACE FUNCTION check_if_omop_neo4j_requires_processing(omop_version varchar, target_table varchar)
RETURNS boolean
AS '
library(setupAthena) 
library(glue)  
library(pg13)
current_version <- get_version()
sql_statement <- 
glue("SELECT * FROM public.process_omop_neo4j_log WHERE omop_version = ''<<omop_version>>'' AND target_table = ''<<target_table>>'';", 
.open = ''<<'', .close = ''>>'')
df <- 
query(sql_statement = sql_statement)
nrow(df) == 0

' LANGUAGE plr;

CREATE OR REPLACE FUNCTION log_omop_neo4j_processing(omop_version varchar, target_table varchar, start_time timestamp, stop_time timestamp)
RETURNS void 
AS '
gl

' LANGUAGE plr;

SELECT check_if_omop_neo4j_requires_processing('test', 'test');

DO 
$$
DECLARE 
  	sql_statement varchar;
BEGIN
	SELECT get_omop_neo4j_sql('{label_col}', '{id_col}', '{name_col}') INTO sql_statement; 
	
	EXECUTE sql_statement;
END;
$$
;