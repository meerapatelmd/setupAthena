/*
PostgreSQL load script authored and contributed by Steve Bedrick (bedricks@ohsu.edu).
Please point each 'copy' statement to your local 'META' installation directory, or wherever you have stored the .RRF files output by MetamorphoSys.
This script has been tested in PostgreSQL 8.2.3 on Mac OS 10.4.10


*/


DROP TABLE IF EXISTS @schema.MRCONSO;
CREATE TABLE @schema.MRCONSO (
	CUI	char(10) NOT NULL,
	LAT	char(3) NOT NULL,
	TS	char(1) NOT NULL,
	LUI	char(10) NOT NULL,
	STT	varchar(3) NOT NULL,
	SUI	char(10) NOT NULL,
	ISPREF	char(1) NOT NULL,
	AUI	varchar(9) NOT NULL,
	SAUI	varchar(50),
	SCUI	varchar(50),
	SDUI	varchar(50),
	SAB	varchar(20) NOT NULL,
	TTY	varchar(20) NOT NULL,
	CODE	varchar(50) NOT NULL,
	STR	text NOT NULL,
	SRL	text NOT NULL,
	SUPPRESS	char(1) NOT NULL,
	CVF	int,
	FILLER_COLUMN text NULL
);
--copy @schema.MRCONSO from '@filePath/MRCONSO.RRF' with delimiter as '|' null as '';
--alter table @schema.mrconso drop column dummy;

