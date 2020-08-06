COPY @schema.@tableName FROM '@vocabulary_file' WITH DELIMITER E'\t' CSV HEADER QUOTE E'\b' ;
