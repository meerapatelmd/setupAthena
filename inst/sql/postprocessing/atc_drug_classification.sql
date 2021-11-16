/* * * * * * * * * * * * * * * * * * * * * * * * * * *
/ OMOP ATC Classification Table
/
/ The ATC Classification is derived from the
/ Relationship table and mapped to the RxNorm Ingredient.
/ - Only valid ATC Classes are included
/ - Only valid relationsihps are included
/ - Both invalid and valid RxNorm Ingredients are given
/ - RxNorm 'Precise Ingredient' concepts are also included
/   in the `in_pin_*` fields
* * * * * * * * * * * * * * * * * * * * * * * * * * */

drop table if exists omop_classification.tmp_atc_classification1;
create table omop_classification.tmp_atc_classification1 (
 atc_1st_id bigint,
 atc_1st_code text,
 atc_1st_name text,
 atc_2nd_id bigint,
 atc_2nd_code text,
 atc_2nd_name text,
 atc_3rd_id bigint,
 atc_3rd_code text,
 atc_3rd_name text,
 atc_4th_id bigint,
 atc_4th_code text,
 atc_4th_name text,
 atc_5th_id bigint,
 atc_5th_code text,
 atc_5th_name text,
 in_pin_id bigint,
 in_pin_code text,
 in_pin_name text
)
;

drop table if exists omop_classification.tmp_atc_classification2;
create table omop_classification.tmp_atc_classification2 (
 atc_1st_id bigint,
 atc_1st_code text,
 atc_1st_name text,
 atc_2nd_id bigint,
 atc_2nd_code text,
 atc_2nd_name text,
 atc_3rd_id bigint,
 atc_3rd_code text,
 atc_3rd_name text,
 atc_4th_id bigint,
 atc_4th_code text,
 atc_4th_name text,
 atc_5th_id bigint,
 atc_5th_code text,
 atc_5th_name text,
 in_pin_id bigint,
 in_pin_code text,
 in_pin_name text
)
;

drop table if exists omop_classification.atc_classification;
create table omop_classification.atc_classification (
 atc_1st_id bigint,
 atc_1st_code text,
 atc_1st_name text,
 atc_2nd_id bigint,
 atc_2nd_code text,
 atc_2nd_name text,
 atc_3rd_id bigint,
 atc_3rd_code text,
 atc_3rd_name text,
 atc_4th_id bigint,
 atc_4th_code text,
 atc_4th_name text,
 atc_5th_id bigint,
 atc_5th_code text,
 atc_5th_name text,
 in_pin_id bigint,
 in_pin_code text,
 in_pin_name text
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
  FROM omop_vocabulary.concept c2
  INNER JOIN (
    SELECT *
    FROM omop_vocabulary.concept_relationship
    WHERE relationship_id = 'Subsumes' AND invalid_reason IS NULL) cr
  ON cr.concept_id_2 = c2.concept_id
  INNER JOIN (
    SELECT * FROM omop_vocabulary.concept
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
FROM omop_vocabulary.concept c2
INNER JOIN (SELECT * FROM omop_vocabulary.concept_relationship WHERE relationship_id = 'Subsumes' AND invalid_reason is null) cr
ON cr.concept_id_2 = c2.concept_id
INNER JOIN (SELECT * FROM omop_vocabulary.concept WHERE vocabulary_id = 'ATC' AND concept_class_id = 'ATC 2nd' AND invalid_reason is null) c1
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
FROM omop_vocabulary.concept c2
INNER JOIN
  (SELECT *
    FROM omop_vocabulary.concept_relationship
    WHERE relationship_id = 'Subsumes'
    AND invalid_reason is null) cr
ON cr.concept_id_2 = c2.concept_id
INNER JOIN
  (SELECT *
    FROM omop_vocabulary.concept
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
FROM omop_vocabulary.concept c2
INNER JOIN (SELECT * FROM omop_vocabulary.concept_relationship WHERE relationship_id = 'Subsumes' AND invalid_reason is null) cr
ON cr.concept_id_2 = c2.concept_id
INNER JOIN (SELECT * FROM omop_vocabulary.concept WHERE vocabulary_id = 'ATC' AND concept_class_id = 'ATC 4th' AND invalid_reason is null) c1
ON cr.concept_id_1 = c1.concept_id
WHERE
 c2.vocabulary_id = 'ATC' AND
 c2.concept_class_id = 'ATC 5th' AND
 c2.invalid_reason is null
);

insert into omop_classification.tmp_atc_classification1
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
c2.concept_id AS in_pin_id,
c2.concept_code AS in_pin_code,
c2.concept_name AS in_pin_name
from part_a a
LEFT JOIN part_b b
ON a.atc_2nd_id = b.atc_2nd_id
LEFT JOIN part_c c
ON b.atc_3rd_id = c.atc_3rd_id
LEFT JOIN part_d d
ON c.atc_4th_id = d.atc_4th_id
INNER JOIN
    (SELECT * FROM omop_vocabulary.concept_relationship WHERE relationship_id = 'ATC - RxNorm pr lat' AND invalid_reason is null) cr
ON cr.concept_id_1 = d.atc_5th_id
INNER JOIN (SELECT * FROM omop_vocabulary.concept WHERE vocabulary_id = 'RxNorm' AND concept_class_id = 'Ingredient' AND invalid_reason is null) c2
  ON cr.concept_id_2 = c2.concept_id
INNER JOIN (
  SELECT DISTINCT
    c1.concept_id AS in_pin_id,
    c2.concept_id AS rxnorm_id,
    c2.concept_code AS rxnorm_code,
    c2.concept_name AS rxnorm_name,
    c2.concept_class_id AS rxnorm_class
  FROM omop_vocabulary.concept c1
  INNER JOIN omop_vocabulary.concept_ancestor ca
  ON ca.ancestor_concept_id = c1.concept_id
  INNER JOIN (SELECT * FROM omop_vocabulary.concept WHERE vocabulary_id = 'RxNorm' AND invalid_reason is null) c2
  ON ca.descendant_concept_id = c2.concept_id
  WHERE
   c1.vocabulary_id = 'RxNorm' AND
   c1.concept_class_id = 'Ingredient' AND
   c1.invalid_reason is null AND
   c1.concept_id <> c2.concept_id
  UNION
  SELECT DISTINCT
    c1.concept_id AS in_pin_id,
    c2.concept_id AS rxnorm_id,
    c2.concept_code AS rxnorm_code,
    c2.concept_name AS rxnorm_name,
    c2.concept_class_id AS rxnorm_class
  FROM omop_vocabulary.concept c1
  INNER JOIN omop_vocabulary.concept_ancestor ca
  ON ca.descendant_concept_id = c1.concept_id
  INNER JOIN (SELECT * FROM omop_vocabulary.concept WHERE vocabulary_id = 'RxNorm' AND invalid_reason is null) c2
  ON ca.ancestor_concept_id = c2.concept_id
  WHERE
   c1.vocabulary_id = 'RxNorm' AND
   c1.concept_class_id = 'Ingredient' AND
   c1.invalid_reason is null AND
   c1.concept_id <> c2.concept_id) ca
 ON ca.in_pin_id = c2.concept_id
);

-- Traverse the RxNorm Precise Ingredient 'Form of' relationship to include Precise Ingredients
INSERT INTO omop_classification.tmp_atc_classification2
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
 pin.concept_id AS in_pin_id,
 pin.concept_code AS in_pin_code,
 pin.concept_name AS in_pin_name
FROM omop_classification.tmp_atc_classification1 tmp1
LEFT JOIN omop_vocabulary.concept_relationship cr
ON cr.concept_id_2 = tmp1.in_pin_id
INNER JOIN omop_vocabulary.concept pin
ON pin.concept_id = cr.concept_id_1
WHERE
  cr.invalid_reason IS NULL AND
  cr.relationship_id = 'Form of'
;


-- Write final table
INSERT INTO omop_classification.atc_classification
SELECT * FROM omop_classification.tmp_atc_classification1
UNION
SELECT * FROM omop_classification.tmp_atc_classification2
;

DROP TABLE omop_classification.tmp_atc_classification1;
DROP TABLE omop_classification.tmp_atc_classification2;

