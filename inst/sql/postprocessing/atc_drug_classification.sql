/* * * * * * * * * * * * * * * * * * * * * * * * * * *
/ OMOP ATC Classification Table
/
/ The ATC Classification is derived from the
/ Relationship table and mapped to the RxNorm Ingredient.
/ - Only valid ATC Classes are included
/ - Only valid relationsihps are included
/ - Both invalid and valid RxNorm Ingredients are given
/ - RxNorm 'Precise Ingredient' concepts are also included
/   in the `ingredient_*` fields
* * * * * * * * * * * * * * * * * * * * * * * * * * */
 DROP TABLE IF EXISTS terminology_log.tmp_terminology;
 CREATE TABLE terminology_log.tmp_terminology (
   start_datetime timestamp without time zone,
   end_datetime timestamp without time zone,
   table_name varchar(60) NOT NULL,
   source_system varchar(100),
   source_version varchar(100),
   jira_ticket varchar(10)
);

 DROP TABLE IF EXISTS terminology_log.tmp_terminology2;
 CREATE TABLE terminology_log.tmp_terminology2 (
   start_datetime timestamp without time zone,
   end_datetime timestamp without time zone,
   table_name varchar(60) NOT NULL,
   source_system varchar(100),
   source_version varchar(100),
   jira_ticket varchar(10)
);


 CREATE TABLE IF NOT EXISTS terminology_log.terminology (
   start_datetime timestamp without time zone,
   end_datetime timestamp without time zone,
   table_name varchar(60),
   source_system varchar(100),
   source_version varchar(100),
   jira_ticket varchar(10)
);



CREATE OR REPLACE PROCEDURE log_start()
AS $$
DECLARE
  start_datetime timestamp without time zone := date_trunc('second', timeofday()::timestamp);
  table_name varchar(60)    := 'atc_classification';
  source_system varchar(25) := 'omop';
  source_version varchar(25);
  jira_ticket varchar(10) := 'INF-222';
BEGIN
  SELECT sa_release_version
    into source_version
    from terminology_log.omop_athena oa
    where oa.transfer_end_datetime  in (
    select max(transfer_end_datetime)
    from terminology_log.omop_athena
    where transfer_end_datetime is not null);


EXECUTE
  'INSERT INTO terminology_log.tmp_terminology(start_datetime, table_name, source_system, source_version, jira_ticket) ' ||
  'VALUES ' ||
  '  (    ' ||
  '   ''' || start_datetime || '''' || ', ' ||
  '   ''' || table_name      || '''' || ', ' ||
  '   ''' || source_system   || '''' || ', ' ||
  '   ''' || source_version  || '''' || ', ' ||
  '   ''' || jira_ticket     || '''' ||
  '  );';

 commit;

END;
$$
LANGUAGE plpgsql;


call log_start();





drop table if exists terminology.tmp_atc_classification1;
create table terminology.tmp_atc_classification1 (
 atc_1st_id bigint,
 atc_1st_code varchar(max),
 atc_1st_name varchar(max),
 atc_2nd_id bigint,
 atc_2nd_code varchar(max),
 atc_2nd_name varchar(max),
 atc_3rd_id bigint,
 atc_3rd_code varchar(max),
 atc_3rd_name varchar(max),
 atc_4th_id bigint,
 atc_4th_code varchar(max),
 atc_4th_name varchar(max),
 atc_5th_id bigint,
 atc_5th_code varchar(max),
 atc_5th_name varchar(max),
 ingredient_id bigint,
 ingredient_code varchar(max),
 ingredient_name varchar(max)
)
;

drop table if exists terminology.tmp_atc_classification2;
create table terminology.tmp_atc_classification2 (
 atc_1st_id bigint,
 atc_1st_code varchar(max),
 atc_1st_name varchar(max),
 atc_2nd_id bigint,
 atc_2nd_code varchar(max),
 atc_2nd_name varchar(max),
 atc_3rd_id bigint,
 atc_3rd_code varchar(max),
 atc_3rd_name varchar(max),
 atc_4th_id bigint,
 atc_4th_code varchar(max),
 atc_4th_name varchar(max),
 atc_5th_id bigint,
 atc_5th_code varchar(max),
 atc_5th_name varchar(max),
 ingredient_id bigint,
 ingredient_code varchar(max),
 ingredient_name varchar(max)
)
;

drop table if exists terminology.atc_classification;
create table terminology.atc_classification (
 atc_1st_id bigint,
 atc_1st_code varchar(max),
 atc_1st_name varchar(max),
 atc_2nd_id bigint,
 atc_2nd_code varchar(max),
 atc_2nd_name varchar(max),
 atc_3rd_id bigint,
 atc_3rd_code varchar(max),
 atc_3rd_name varchar(max),
 atc_4th_id bigint,
 atc_4th_code varchar(max),
 atc_4th_name varchar(max),
 atc_5th_id bigint,
 atc_5th_code varchar(max),
 atc_5th_name varchar(max),
 ingredient_id bigint,
 ingredient_code varchar(max),
 ingredient_name varchar(max)
)
;

drop table if exists part_a;
create temp table part_a AS (
SELECT DISTINCT
  c1.concept_id AS atc_1st_id,
  c1.concept_code AS atc_1st_code,
  c1.concept_name AS atc_1st_name,
  c2.concept_id AS atc_2nd_id,
  c2.concept_code AS atc_2nd_code,
  c2.concept_name AS atc_2nd_name
  FROM omop_athena.concept c2
  INNER JOIN (
    SELECT *
    FROM omop_athena.concept_relationship
    WHERE relationship_id = 'Subsumes' AND invalid_reason IS NULL) cr
  ON cr.concept_id_2 = c2.concept_id
  INNER JOIN (
    SELECT * FROM omop_athena.concept
    WHERE
      vocabulary_id = 'ATC' AND
      concept_class_id = 'ATC 1st' ) c1
  ON cr.concept_id_1 = c1.concept_id
  WHERE
    c2.vocabulary_id = 'ATC' AND
    c2.concept_class_id = 'ATC 2nd' AND
    c2.invalid_reason is NULL
);

drop table if exists part_b;
create temp table part_b AS (
SELECT DISTINCT
  c1.concept_id AS atc_2nd_id,
  c1.concept_code AS atc_2nd_code,
  c1.concept_name AS atc_2nd_name,
  c2.concept_id AS atc_3rd_id,
  c2.concept_code AS atc_3rd_code,
  c2.concept_name AS atc_3rd_name
FROM omop_athena.concept c2
INNER JOIN (SELECT * FROM omop_athena.concept_relationship WHERE relationship_id = 'Subsumes' AND invalid_reason is null) cr
ON cr.concept_id_2 = c2.concept_id
INNER JOIN (SELECT * FROM omop_athena.concept WHERE vocabulary_id = 'ATC' AND concept_class_id = 'ATC 2nd' AND invalid_reason is null) c1
ON cr.concept_id_1 = c1.concept_id
WHERE
 c2.vocabulary_id = 'ATC' AND
 c2.concept_class_id = 'ATC 3rd' AND
 c2.invalid_reason is null)
 ;

drop table if exists part_c;
create temp table part_c AS (
SELECT DISTINCT
  c1.concept_id AS atc_3rd_id,
  c1.concept_code AS atc_3rd_code,
  c1.concept_name AS atc_3rd_name,
  c2.concept_id AS atc_4th_id,
  c2.concept_code AS atc_4th_code,
  c2.concept_name AS atc_4th_name
FROM omop_athena.concept c2
INNER JOIN
  (SELECT *
    FROM omop_athena.concept_relationship
    WHERE relationship_id = 'Subsumes'
    AND invalid_reason is null) cr
ON cr.concept_id_2 = c2.concept_id
INNER JOIN
  (SELECT *
    FROM omop_athena.concept
    WHERE vocabulary_id = 'ATC'
    AND concept_class_id = 'ATC 3rd'
    AND invalid_reason is null) c1
ON cr.concept_id_1 = c1.concept_id
WHERE
 c2.vocabulary_id = 'ATC' AND
 c2.concept_class_id = 'ATC 4th' AND
 c2.invalid_reason is null
);

drop table if exists part_d;
create temp table part_d AS (
SELECT DISTINCT
  c1.concept_id AS atc_4th_id,
  c1.concept_code AS atc_4th_code,
  c1.concept_name AS atc_4th_name,
  c2.concept_id AS atc_5th_id,
  c2.concept_code AS atc_5th_code,
  c2.concept_name AS atc_5th_name
FROM omop_athena.concept c2
INNER JOIN (SELECT * FROM omop_athena.concept_relationship WHERE relationship_id = 'Subsumes' AND invalid_reason is null) cr
ON cr.concept_id_2 = c2.concept_id
INNER JOIN (SELECT * FROM omop_athena.concept WHERE vocabulary_id = 'ATC' AND concept_class_id = 'ATC 4th' AND invalid_reason is null) c1
ON cr.concept_id_1 = c1.concept_id
WHERE
 c2.vocabulary_id = 'ATC' AND
 c2.concept_class_id = 'ATC 5th' AND
 c2.invalid_reason is null
);

insert into terminology.tmp_atc_classification1
(
SELECT DISTINCT
 a.atc_1st_id,
 a.atc_1st_code,
 a.atc_1st_name,
 a.atc_2nd_id,
 a.atc_2nd_code,
 a.atc_2nd_name,
 b.atc_3rd_id,
 b.atc_3rd_code,
 b.atc_3rd_name,
 c.atc_4th_id,
 c.atc_4th_code,
 c.atc_4th_name,
 d.atc_5th_id,
 d.atc_5th_code,
 d.atc_5th_name,
c2.concept_id AS ingredient_id,
c2.concept_code AS ingredient_code,
c2.concept_name AS ingredient_name
from part_a a
LEFT JOIN part_b b
ON a.atc_2nd_id = b.atc_2nd_id
LEFT JOIN part_c c
ON b.atc_3rd_id = c.atc_3rd_id
LEFT JOIN part_d d
ON c.atc_4th_id = d.atc_4th_id
INNER JOIN
    (SELECT * FROM omop_athena.concept_relationship WHERE relationship_id = 'ATC - RxNorm pr lat' AND invalid_reason is null) cr
ON cr.concept_id_1 = d.atc_5th_id
INNER JOIN (SELECT * FROM omop_athena.concept WHERE vocabulary_id = 'RxNorm' AND concept_class_id = 'Ingredient' AND invalid_reason is null) c2
  ON cr.concept_id_2 = c2.concept_id
INNER JOIN (
  SELECT DISTINCT
    c1.concept_id AS ingredient_id,
    c2.concept_id AS rxnorm_id,
    c2.concept_code AS rxnorm_code,
    c2.concept_name AS rxnorm_name,
    c2.concept_class_id AS rxnorm_class
  FROM omop_athena.concept c1
  INNER JOIN omop_athena.concept_ancestor ca
  ON ca.ancestor_concept_id = c1.concept_id
  INNER JOIN (SELECT * FROM omop_athena.concept WHERE vocabulary_id = 'RxNorm' AND invalid_reason is null) c2
  ON ca.descendant_concept_id = c2.concept_id
  WHERE
   c1.vocabulary_id = 'RxNorm' AND
   c1.concept_class_id = 'Ingredient' AND
   c1.invalid_reason is null AND
   c1.concept_id <> c2.concept_id
  UNION
  SELECT DISTINCT
    c1.concept_id AS ingredient_id,
    c2.concept_id AS rxnorm_id,
    c2.concept_code AS rxnorm_code,
    c2.concept_name AS rxnorm_name,
    c2.concept_class_id AS rxnorm_class
  FROM omop_athena.concept c1
  INNER JOIN omop_athena.concept_ancestor ca
  ON ca.descendant_concept_id = c1.concept_id
  INNER JOIN (SELECT * FROM omop_athena.concept WHERE vocabulary_id = 'RxNorm' AND invalid_reason is null) c2
  ON ca.ancestor_concept_id = c2.concept_id
  WHERE
   c1.vocabulary_id = 'RxNorm' AND
   c1.concept_class_id = 'Ingredient' AND
   c1.invalid_reason is null AND
   c1.concept_id <> c2.concept_id) ca
 ON ca.ingredient_id = c2.concept_id
);

-- Traverse the RxNorm Precise Ingredient 'Form of' relationship to include Precise Ingredients
INSERT INTO terminology.tmp_atc_classification2
SELECT DISTINCT
 tmp1.atc_1st_id,
 tmp1.atc_1st_code,
 tmp1.atc_1st_name,
 tmp1.atc_2nd_id,
 tmp1.atc_2nd_code,
 tmp1.atc_2nd_name,
 tmp1.atc_3rd_id,
 tmp1.atc_3rd_code,
 tmp1.atc_3rd_name,
 tmp1.atc_4th_id,
 tmp1.atc_4th_code,
 tmp1.atc_4th_name,
 tmp1.atc_5th_id,
 tmp1.atc_5th_code,
 tmp1.atc_5th_name,
 pin.concept_id AS ingredient_id,
 pin.concept_code AS ingredient_code,
 pin.concept_name AS ingredient_name
FROM terminology.tmp_atc_classification1 tmp1
LEFT JOIN omop_athena.concept_relationship cr
ON cr.concept_id_2 = tmp1.ingredient_id
INNER JOIN omop_athena.concept pin
ON pin.concept_id = cr.concept_id_1
WHERE
  cr.invalid_reason IS NULL AND
  cr.relationship_id = 'Form of'
;


-- Write final table
INSERT INTO terminology.atc_classification
SELECT * FROM terminology.tmp_atc_classification1
UNION
SELECT * FROM terminology.tmp_atc_classification2
;

commit;

CREATE OR REPLACE PROCEDURE log_end()
AS $$
DECLARE
  start_datetime2 timestamp without time zone;
  end_datetime2 timestamp without time zone := date_trunc('second', timeofday()::timestamp);
  table_name2 varchar(60);
  source_system2 varchar(25);
  source_version2 varchar(25);
  jira_ticket2 varchar(10);
BEGIN
  SELECT start_datetime
  INTO start_datetime2
  FROM terminology_log.tmp_terminology;

  SELECT table_name
  INTO table_name2
  FROM terminology_log.tmp_terminology;

  SELECT source_system
  INTO source_system2
  FROM terminology_log.tmp_terminology;

  SELECT source_version
  INTO source_version2
  FROM terminology_log.tmp_terminology;

  SELECT jira_ticket
  INTO jira_ticket2
  FROM terminology_log.tmp_terminology;

EXECUTE
  'INSERT INTO terminology_log.tmp_terminology2 ' ||
  'VALUES ' ||
  '  (    ' ||
  '   ''' || start_datetime2  || '''' || ', ' ||
  '   ''' || end_datetime2    || '''' || ', ' ||
  '   ''' || table_name2      || '''' || ', ' ||
  '   ''' || source_system2   || '''' || ', ' ||
  '   ''' || source_version2  || '''' || ', ' ||
  '   ''' || jira_ticket2     || '''' ||
  '  );';

 insert into terminology_log.terminology
 select * from terminology_log.tmp_terminology2;

END;
$$
LANGUAGE plpgsql;


call log_end();


DROP table if EXISTS terminology_log.tmp_terminology;
DROP table if EXISTS terminology_log.tmp_terminology2;
DROP TABLE terminology.tmp_atc_classification1;
DROP TABLE terminology.tmp_atc_classification2;

