load data local infile '@filePath/MRCONSO.RRF' into table @schema.MRCONSO fields terminated by '|' ESCAPED BY '' lines terminated by '\n';

load data local infile '@filePath/MRHIER.RRF' into table @schema.MRHIER fields terminated by '|' ESCAPED BY '' lines terminated by '\n';

load data local infile '@filePath/MRMAP.RRF' into table @schema.MRMAP fields terminated by '|' ESCAPED BY '' lines terminated by '\n';

load data local infile '@filePath/MRSMAP.RRF' into table @schema.MRSMAP fields terminated by '|' ESCAPED BY '' lines terminated by '\n';

load data local infile '@filePath/MRSAT.RRF' into table @schema.MRSAT fields terminated by '|' ESCAPED BY '' lines terminated by '\n';

load data local infile '@filePath/MRREL.RRF' into table @schema.MRREL fields terminated by '|' ESCAPED BY '' lines terminated by '\n';
