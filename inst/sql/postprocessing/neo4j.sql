CREATE TABLE IF NOT EXISTS public.process_omop_neo4j_log (
    process_start_datetime timestamp without time zone,
    process_stop_datetime timestamp without time zone,
    omop_version character varying(255),
    target_table character varying(255),
    target_row_ct numeric

);

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
	SELECT sa_version
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


-- DROP FUNCTION check_if_requires_processing(character varying,character varying,character varying);
create or replace function check_if_omop_neo4j_requires_processing(omop_version varchar, target_table varchar)
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
		FROM public.process_omop_neo4j_log l
		WHERE
		  l.omop_version = ''%s'' AND
		  l.target_table = ''%s'' AND
		  l.process_stop_datetime IS NOT NULL
		  ;
	    ',
	    omop_version,
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


-- Create Schema if doesn't exist
CREATE SCHEMA IF NOT EXISTS omop_neo4j;


-- Create Edge Table
DO
$$
DECLARE
  omop_version varchar;
  requires_processing boolean;
  target_table varchar := 'edge';
  target_rows bigint;
  start_timestamp timestamp;
  stop_timestamp timestamp;

BEGIN
  SELECT sa_release_version FROM public.setup_athena_log WHERE sa_datetime IN (SELECT MAX(sa_datetime) FROM public.setup_athena_log)
  INTO omop_version;

  SELECT check_if_omop_neo4j_requires_processing(omop_version, target_table)
  INTO requires_processing;


  IF requires_processing THEN

        SELECT get_log_timestamp()
  	INTO start_timestamp
  	;

  	PERFORM notify_start('processing EDGE');

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

        PERFORM notify_completion('processing EDGE');

		SELECT get_log_timestamp()
		INTO stop_timestamp
		;


		SELECT get_row_count('omop_neo4j.edge')
		INTO target_rows
		;


		EXECUTE
		  format(
		    '
			INSERT INTO public.process_omop_neo4j_log
			VALUES (
			  ''%s'',
			  ''%s'',
			  ''%s'',
			  ''%s'',
			  ''%s'');
			',
			  start_timestamp,
			  stop_timestamp,
			  omop_version,
			  target_table,
			  target_rows);


		PERFORM notify_timediff('processing EDGE', start_timestamp, stop_timestamp);
   END IF;
END;
$$
;

COMMIT;

-- Create Node Table
DO
$$
DECLARE
  omop_version varchar;
  requires_processing boolean;
  target_table varchar := 'node';
  target_rows bigint;
  start_timestamp timestamp;
  stop_timestamp timestamp;

BEGIN
  SELECT sa_release_version FROM public.setup_athena_log WHERE sa_datetime IN (SELECT MAX(sa_datetime) FROM public.setup_athena_log)
  INTO omop_version;

  SELECT check_if_omop_neo4j_requires_processing(omop_version, target_table)
  INTO requires_processing;


  IF requires_processing THEN

        SELECT get_log_timestamp()
  	INTO start_timestamp
  	;

  	PERFORM notify_start('processing NODE');

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
  STRING_AGG(cs.concept_synonym_name, '|') AS concept_synonyms,
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

        PERFORM notify_completion('processing NODE');

		SELECT get_log_timestamp()
		INTO stop_timestamp
		;


		SELECT get_row_count('omop_neo4j.node')
		INTO target_rows
		;


		EXECUTE
		  format(
		    '
			INSERT INTO public.process_omop_neo4j_log
			VALUES (
			  ''%s'',
			  ''%s'',
			  ''%s'',
			  ''%s'',
			  ''%s'');
			',
			  start_timestamp,
			  stop_timestamp,
			  omop_version,
			  target_table,
			  target_rows);


		PERFORM notify_timediff('processing NODE', start_timestamp, stop_timestamp);
   END IF;
END;
$$
;


-- Create Pre-Edge Header Table
DO
$$
DECLARE
  omop_version varchar;
  requires_processing boolean;
  target_table varchar := 'pre_edge_header';
  target_rows bigint;
  start_timestamp timestamp;
  stop_timestamp timestamp;

BEGIN
  SELECT sa_release_version FROM public.setup_athena_log WHERE sa_datetime IN (SELECT MAX(sa_datetime) FROM public.setup_athena_log)
  INTO omop_version;

  SELECT check_if_omop_neo4j_requires_processing(omop_version, target_table)
  INTO requires_processing;


  IF requires_processing THEN

        SELECT get_log_timestamp()
  	INTO start_timestamp
  	;

  	PERFORM notify_start('processing PRE_EDGE_HEADER');

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


        PERFORM notify_completion('processing PRE_EDGE_HEADER');

		SELECT get_log_timestamp()
		INTO stop_timestamp
		;


		SELECT get_row_count('omop_neo4j.pre_edge_header')
		INTO target_rows
		;


		EXECUTE
		  format(
		    '
			INSERT INTO public.process_omop_neo4j_log
			VALUES (
			  ''%s'',
			  ''%s'',
			  ''%s'',
			  ''%s'',
			  ''%s'');
			',
			  start_timestamp,
			  stop_timestamp,
			  omop_version,
			  target_table,
			  target_rows);


		PERFORM notify_timediff('processing PRE_EDGE_HEADER', start_timestamp, stop_timestamp);
   END IF;
END;
$$
;



-- Create Pre-Edge Table
DO
$$
DECLARE
  omop_version varchar;
  requires_processing boolean;
  target_table varchar := 'pre_edge';
  target_rows bigint;
  start_timestamp timestamp;
  stop_timestamp timestamp;

BEGIN
  SELECT sa_release_version FROM public.setup_athena_log WHERE sa_datetime IN (SELECT MAX(sa_datetime) FROM public.setup_athena_log)
  INTO omop_version;

  SELECT check_if_omop_neo4j_requires_processing(omop_version, target_table)
  INTO requires_processing;


  IF requires_processing THEN

        SELECT get_log_timestamp()
  	INTO start_timestamp
  	;

  	PERFORM notify_start('processing PRE_EDGE');

        DROP TABLE IF EXISTS omop_neo4j.pre_edge;
        CREATE TABLE omop_neo4j.pre_edge AS (
                SELECT
                        concept_id_1    AS start_id_col,
                        concept_id_2    AS end_id_col,
                        relationship_id AS type_col,
                        e.*
        FROM omop_neo4j.edge e
        );


        PERFORM notify_completion('processing PRE_EDGE');

		SELECT get_log_timestamp()
		INTO stop_timestamp
		;


		SELECT get_row_count('omop_neo4j.pre_edge')
		INTO target_rows
		;


		EXECUTE
		  format(
		    '
			INSERT INTO public.process_omop_neo4j_log
			VALUES (
			  ''%s'',
			  ''%s'',
			  ''%s'',
			  ''%s'',
			  ''%s'');
			',
			  start_timestamp,
			  stop_timestamp,
			  omop_version,
			  target_table,
			  target_rows);


		PERFORM notify_timediff('processing PRE_EDGE', start_timestamp, stop_timestamp);
   END IF;
END;
$$
;

-- Create Pre-Node Header Table
DO
$$
DECLARE
  omop_version varchar;
  requires_processing boolean;
  target_table varchar := 'pre_node_header';
  target_rows bigint;
  start_timestamp timestamp;
  stop_timestamp timestamp;

BEGIN
  SELECT sa_release_version FROM public.setup_athena_log WHERE sa_datetime IN (SELECT MAX(sa_datetime) FROM public.setup_athena_log)
  INTO omop_version;

  SELECT check_if_omop_neo4j_requires_processing(omop_version, target_table)
  INTO requires_processing;


  IF requires_processing THEN

        SELECT get_log_timestamp()
  	INTO start_timestamp
  	;

  	PERFORM notify_start('processing PRE_NODE_HEADER');

        DROP TABLE IF EXISTS omop_neo4j.pre_node_header;
        CREATE TABLE omop_neo4j.pre_node_header AS (
          SELECT
            domain_id AS label_col,
            concept_id   AS id_col,
            concept_name  AS name_col,
            n.*
          FROM omop_neo4j.node n
          LIMIT 5
        );

        PERFORM notify_completion('processing PRE_NODE_HEADER');

		SELECT get_log_timestamp()
		INTO stop_timestamp
		;


		SELECT get_row_count('omop_neo4j.pre_node_header')
		INTO target_rows
		;


		EXECUTE
		  format(
		    '
			INSERT INTO public.process_omop_neo4j_log
			VALUES (
			  ''%s'',
			  ''%s'',
			  ''%s'',
			  ''%s'',
			  ''%s'');
			',
			  start_timestamp,
			  stop_timestamp,
			  omop_version,
			  target_table,
			  target_rows);


		PERFORM notify_timediff('processing PRE_NODE_HEADER', start_timestamp, stop_timestamp);
   END IF;
END;
$$
;

-- Create Pre-Node Table
DO
$$
DECLARE
  omop_version varchar;
  requires_processing boolean;
  target_table varchar := 'pre_node';
  target_rows bigint;
  start_timestamp timestamp;
  stop_timestamp timestamp;

BEGIN
  SELECT sa_release_version FROM public.setup_athena_log WHERE sa_datetime IN (SELECT MAX(sa_datetime) FROM public.setup_athena_log)
  INTO omop_version;

  SELECT check_if_omop_neo4j_requires_processing(omop_version, target_table)
  INTO requires_processing;


  IF requires_processing THEN

        SELECT get_log_timestamp()
  	INTO start_timestamp
  	;

  	PERFORM notify_start('processing PRE_NODE');

        DROP TABLE IF EXISTS omop_neo4j.pre_node;
        CREATE TABLE omop_neo4j.pre_node_header AS (
          SELECT
            domain_id AS label_col,
            concept_id   AS id_col,
            concept_name  AS name_col,
            n.*
          FROM omop_neo4j.node n
        );

        PERFORM notify_completion('processing PRE_NODE');

		SELECT get_log_timestamp()
		INTO stop_timestamp
		;


		SELECT get_row_count('omop_neo4j.pre_node')
		INTO target_rows
		;


		EXECUTE
		  format(
		    '
			INSERT INTO public.process_omop_neo4j_log
			VALUES (
			  ''%s'',
			  ''%s'',
			  ''%s'',
			  ''%s'',
			  ''%s'');
			',
			  start_timestamp,
			  stop_timestamp,
			  omop_version,
			  target_table,
			  target_rows);


		PERFORM notify_timediff('processing PRE_NODE', start_timestamp, stop_timestamp);
   END IF;
END;
$$
;
