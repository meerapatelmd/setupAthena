/* * * * * * * * * * * * * * * * * * * * * * * * * * *
/ OMOP ATC Classification Table
/
/ The ATC Classification is derived from the
/ Relationship table and mapped to the RxNorm Ingredient.
/ - Only valid ATC Classes are included
/ - Only valid relationsihps are included
/ - Both invalid and valid RxNorm Ingredients are given
/ - RxNorm 'Precise Ingredient' concepts are also included
/   in the `in_pin_min_*` fields
* * * * * * * * * * * * * * * * * * * * * * * * * * */
CREATE TABLE IF NOT EXISTS public.process_{misc_schema}_log (
    process_start_datetime timestamp without time zone,
    process_stop_datetime timestamp without time zone,
    omop_version character varying(255),
    target_schema character varying(255),
    source_table character varying(255),
    target_table character varying(255),
    source_row_ct numeric,
    target_row_ct numeric
);

CREATE TABLE IF NOT EXISTS public.setup_{misc_schema}_log (
    soc_datetime timestamp without time zone,
    omop_version character varying(255),
    target_schema character varying(255),
    tablename character varying(63),
    table_rows bigint
);

/**************************************************************************
Logging Functions
**************************************************************************/

create or replace function get_log_timestamp()
returns timestamp without time zone
language plpgsql
as
$$
declare
  log_timestamp timestamp without time zone;
begin
  SELECT date_trunc('second', timeofday()::timestamp)
  INTO log_timestamp;

  RETURN log_timestamp;
END;
$$;

create or replace function get_omop_version()
returns varchar
language plpgsql
as
$$
declare
	omop_version varchar;
begin
	SELECT sa_release_version
	INTO omop_version
	FROM public.setup_athena_log
	WHERE sa_datetime IN (SELECT MAX(sa_datetime) FROM public.setup_athena_log);

  	RETURN omop_version;
END;
$$;

create or replace function get_row_count(_tbl varchar)
returns bigint
language plpgsql
AS
$$
DECLARE
  row_count bigint;
BEGIN
  EXECUTE
    format('
	  SELECT COUNT(*)
	  FROM %s;
	 ',
	 _tbl)
  INTO row_count;

  RETURN row_count;
END;
$$;


create or replace function check_if_omop_requires_processing(omop_version varchar, source_table varchar, target_table varchar)
returns boolean
language plpgsql
as
$$
declare
    row_count integer;
	requires_processing boolean;
begin
	EXECUTE
	  format(
	    '
		SELECT COUNT(*)
		FROM public.process_{misc_schema}_log l
		WHERE
		  l.omop_version = ''%s'' AND
		  l.source_table = ''%s'' AND
		  l.target_table = ''%s'' AND
		  l.process_stop_datetime IS NOT NULL
		  ;
	    ',
	    omop_version,
	    source_table,
	    target_table
	  )
	  INTO row_count;


	IF row_count = 0
	  THEN requires_processing := TRUE;
	  ELSE requires_processing := FALSE;
	END IF;

  	RETURN requires_processing;
END;
$$;


create or replace function notify_iteration(iteration int, total_iterations int, objectname varchar)
returns void
language plpgsql
as
$$
declare
  notice_timestamp timestamp;
begin
  SELECT get_log_timestamp()
  INTO notice_timestamp
  ;

  RAISE NOTICE '[%] %/% %', notice_timestamp, iteration, total_iterations, objectname;
END;
$$;

create or replace function notify_start(report varchar)
returns void
language plpgsql
as
$$
declare
  notice_timestamp timestamp;
begin
  SELECT get_log_timestamp()
  INTO notice_timestamp
  ;

  RAISE NOTICE '[%] Started %', notice_timestamp, report;
END;
$$;

create or replace function notify_completion(report varchar)
returns void
language plpgsql
as
$$
declare
  notice_timestamp timestamp;
begin
  SELECT get_log_timestamp()
  INTO notice_timestamp
  ;

  RAISE NOTICE '[%] Completed %', notice_timestamp, report;
END;
$$;


create or replace function notify_timediff(report varchar, start_timestamp timestamp, stop_timestamp timestamp)
returns void
language plpgsql
as
$$
begin
	RAISE NOTICE '% required %s to complete.', report, stop_timestamp - start_timestamp;
end;
$$
;

create or replace function vocab_id_to_tablename(vocabulary_id varchar)
returns varchar
language plpgsql
as
$$
declare
  tablename varchar;
begin
	SELECT REGEXP_REPLACE(vocabulary_id, '[[:punct:]]', '_', 'g') INTO tablename;

	RETURN tablename;
end;
$$
;


DO
$$
DECLARE
	requires_processing boolean;
	start_timestamp timestamp;
	stop_timestamp timestamp;
	omop_version varchar;
	source_table varchar;
	source_rows bigint;
	target_table varchar;
	target_rows bigint;
BEGIN
	SELECT get_omop_version()
	INTO omop_version;

	source_table := 'CONCEPT_RELATIONSHIP';
	target_table := 'OMOP_ATC_CLASSIFICATION';

	SELECT check_if_omop_requires_processing(omop_version, source_table, target_table)
	INTO requires_processing;


	IF requires_processing THEN

		SELECT get_log_timestamp()
  		INTO start_timestamp
  		;

		drop table if exists {misc_schema}.tmp_omop_atc_classification1;
		create table {misc_schema}.tmp_omop_atc_classification1 (
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
		 in_pin_min_id bigint,
		 in_pin_min_code text,
		 in_pin_min_name text
		)
		;

		drop table if exists {misc_schema}.tmp_omop_atc_classification2;
		create table {misc_schema}.tmp_omop_atc_classification2 (
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
		 in_pin_min_id bigint,
		 in_pin_min_code text,
		 in_pin_min_name text
		)
		;

		drop table if exists {misc_schema}.tmp_omop_atc_classification3;
		create table {misc_schema}.tmp_omop_atc_classification3 (
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
		 in_pin_min_id bigint,
		 in_pin_min_code text,
		 in_pin_min_name text
		)
		;

		drop table if exists {misc_schema}.omop_atc_classification;
		create table {misc_schema}.omop_atc_classification (
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
		 in_pin_min_id bigint,
		 in_pin_min_code text,
		 in_pin_min_name text
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

		insert into {misc_schema}.tmp_omop_atc_classification1
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
		c2.concept_id AS in_pin_min_id,
		c2.concept_code AS in_pin_min_code,
		c2.concept_name AS in_pin_min_name
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
		    c1.concept_id AS in_pin_min_id,
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
		    c1.concept_id AS in_pin_min_id,
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
		 ON ca.in_pin_min_id = c2.concept_id
		);

		-- Traverse the RxNorm Precise Ingredient 'Form of' relationship to include Precise Ingredients
		INSERT INTO {misc_schema}.tmp_omop_atc_classification2
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
		 pin.concept_id AS in_pin_min_id,
		 pin.concept_code AS in_pin_min_code,
		 pin.concept_name AS in_pin_min_name
		FROM {misc_schema}.tmp_omop_atc_classification1 tmp1
		LEFT JOIN omop_vocabulary.concept_relationship cr
		ON cr.concept_id_2 = tmp1.in_pin_min_id
		INNER JOIN omop_vocabulary.concept pin
		ON pin.concept_id = cr.concept_id_1
		WHERE
		  cr.invalid_reason IS NULL AND
		  cr.relationship_id = 'Form of'
		;

	        -- Traverse the RxNorm Multiple Ingredient 'Mapped from' relationship
		INSERT INTO {misc_schema}.tmp_omop_atc_classification3
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
		 ming.concept_id AS in_pin_min_id,
		 ming.concept_code AS in_pin_min_code,
		 ming.concept_name AS in_pin_min_name
		FROM {misc_schema}.tmp_omop_atc_classification1 tmp1
		LEFT JOIN omop_vocabulary.concept_relationship cr
		ON cr.concept_id_2 = tmp1.in_pin_min_id
		INNER JOIN omop_vocabulary.concept ming
		ON ming.concept_id = cr.concept_id_1
		WHERE
		  cr.invalid_reason IS NULL AND
		  ming.vocabulary_id = 'RxNorm' AND
		  ming.concept_class_id = 'Multiple Ingredients'
		;


		-- Write final table
		INSERT INTO {misc_schema}.omop_atc_classification
		SELECT * FROM {misc_schema}.tmp_omop_atc_classification1
		UNION
		SELECT * FROM {misc_schema}.tmp_omop_atc_classification2
		UNION
		SELECT * FROM {misc_schema}.tmp_omop_atc_classification3
		;

		DROP TABLE {misc_schema}.tmp_omop_atc_classification1;
		DROP TABLE {misc_schema}.tmp_omop_atc_classification2;
		DROP TABLE {misc_schema}.tmp_omop_atc_classification3;

		SELECT get_log_timestamp()
		INTO stop_timestamp
		;


		SELECT COUNT(*)
		INTO source_rows
		FROM omop_vocabulary.concept_relationship
		;

		SELECT COUNT(*)
		INTO target_rows
		FROM {misc_schema}.omop_atc_classification
		;


		EXECUTE
		format(
			'
			INSERT INTO public.setup_{misc_schema}_log
			VALUES (
			''%s'', -- soc_datetime timestamp without time zone,
	    	''%s'', -- omop_version character varying(255),
	    	''%s'', -- target_schema character varying(255),
	    	''%s'', -- tablename character varying(63),
	    	''%s'' -- table_rows bigint
	    	);',
	    	stop_timestamp,
	    	omop_version,
	    	'{misc_schema}',
	    	target_table,
	    	target_rows
	    	);


		EXECUTE
		format(
		'
		INSERT INTO public.process_{misc_schema}_log
		VALUES (
		''%s'', -- process_start_datetime timestamp without time zone,
    		''%s'', -- process_stop_datetime timestamp without time zone,
    		''%s'', -- omop_version character varying(255),
    		''%s'', -- target_schema character varying(255),
    		''%s'', -- source_table character varying(255),
    		''%s'', -- target_table character varying(255),
    		''%s'', -- source_row_ct numeric,
    		''%s'' -- target_row_ct numeric
		);
		',
			start_timestamp, -- process_start_datetime timestamp without time zone,
    		stop_timestamp,  -- process_stop_datetime timestamp without time zone,
    		omop_version, -- omop_version character varying(255),
    		'{misc_schema}', -- target_schema character varying(255),
    		source_table, -- source_table character varying(255),
    		target_table, -- target_table character varying(255),
    		source_rows, -- source_row_ct numeric,
    		target_rows -- target_row_ct numeric
    		);

END IF;
END;
$$
;
