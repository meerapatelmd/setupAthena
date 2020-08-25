/*
PostgreSQL load script authored and contributed by Steve Bedrick (bedricks@ohsu.edu).
Please point each 'copy' statement to your local 'META' installation directory, or wherever you have stored the .RRF files output by MetamorphoSys.
This script has been tested in PostgreSQL 8.2.3 on Mac OS 10.4.10


*/

DROP TABLE MRCOC;
CREATE TABLE MRCOC (
	CUI1	char(8) NOT NULL,
	AUI1	varchar(9) NOT NULL,
	CUI2	char(8),
	AUI2	varchar(9),
	SAB	varchar(20) NOT NULL,
	COT	varchar(3) NOT NULL,
	COF	int,
	COA	text,
	CVF	int,
	dummy char(1)
);
copy MRCOC from '@filePath/MRCOC.RRF' with delimiter as '|' null as '';
alter table mrcoc drop column dummy;

DROP TABLE MRCOLS;
CREATE TABLE MRCOLS (
	COL	varchar(20),
	DES	varchar(200),
	REF	varchar(20),
	MIN	int,
	AV	numeric(5,2),
	MAX	int,
	FIL	varchar(50),
	DTY	varchar(20),
	dummy char(1)
);
copy MRCOLS from '@filePath/MRCOLS.RRF' with delimiter as '|' null as '';
alter table mrcols drop column dummy;

DROP TABLE MRCONSO;
CREATE TABLE MRCONSO (
	CUI	char(8) NOT NULL,
	LAT	char(3) NOT NULL,
	TS	char(1) NOT NULL,
	LUI	char(8) NOT NULL,
	STT	varchar(3) NOT NULL,
	SUI	char(8) NOT NULL,
	ISPREF	char(1) NOT NULL,
	AUI	varchar(9) NOT NULL,
	SAUI	varchar(50),
	SCUI	varchar(50),
	SDUI	varchar(50),
	SAB	varchar(20) NOT NULL,
	TTY	varchar(20) NOT NULL,
	CODE	varchar(50) NOT NULL,
	STR	text NOT NULL,
	SRL	int NOT NULL,
	SUPPRESS	char(1) NOT NULL,
	CVF	int,
	dummy char(1)
);
copy MRCONSO from '@filePath/MRCONSO.RRF' with delimiter as '|' null as '';
alter table mrconso drop column dummy;

DROP TABLE MRCUI;
CREATE TABLE MRCUI (
	CUI1	char(8) NOT NULL,
	VER	varchar(10) NOT NULL,
	REL	varchar(4) NOT NULL,
	RELA	varchar(100),
	MAPREASON	text,
	CUI2	char(8),
	MAPIN	char(1),
	dummy char(1)
);
copy MRCUI from '@filePath/MRCUI.RRF' with delimiter as '|' null as '';
alter table mrcui drop column dummy;

DROP TABLE MRCXT;
CREATE TABLE MRCXT (
	CUI	char(8),
	SUI	char(8),
	AUI	varchar(9),
	SAB	varchar(20),
	CODE	varchar(50),
	CXN	int,
	CXL	char(3),
	RANK	int,
	CXS	text,
	CUI2	char(8),
	AUI2	varchar(9),
	HCD	varchar(50),
	RELA	varchar(100),
	XC	varchar(1),
	CVF	int,
	dummy char(1)
);
copy MRCXT from '@filePath/MRCXT.RRF' with delimiter as '|' null as '';
alter table mrcxt drop column dummy;

DROP TABLE MRDEF;
CREATE TABLE MRDEF (
	CUI	char(8) NOT NULL,
	AUI	varchar(9) NOT NULL,
	ATUI	varchar(10) NOT NULL,
	SATUI	varchar(50),
	SAB	varchar(20) NOT NULL,
	DEF	text NOT NULL,
	SUPPRESS	char(1) NOT NULL,
	CVF	int,
	dummy char(1)
);
copy MRDEF from '@filePath/MRDEF.RRF' with delimiter as '|' null as '';
alter table mrdef drop column dummy;

DROP TABLE MRDOC;
CREATE TABLE MRDOC (
	DOCKEY	varchar(50) NOT NULL,
	VALUE	varchar(200),
	TYPE	varchar(50) NOT NULL,
	EXPL	text,
	dummy char(1)
);
copy MRDOC from '@filePath/MRDOC.RRF' with delimiter as '|' null as '';
alter table mrdoc drop column dummy;

DROP TABLE MRFILES;
CREATE TABLE MRFILES (
	FIL	varchar(50),
	DES	varchar(200),
	FMT	text,
	CLS	int,
	RWS	int,
	BTS	bigint,
	dummy char(1)
);
copy MRFILES from '@filePath/MRFILES.RRF' with delimiter as '|' null as '';
alter table mrfiles drop column dummy;

DROP TABLE MRHIER;
CREATE TABLE MRHIER (
	CUI	char(8) NOT NULL,
	AUI	varchar(9) NOT NULL,
	CXN	int NOT NULL,
	PAUI	varchar(9),
	SAB	varchar(20) NOT NULL,
	RELA	varchar(100),
	PTR	text,
	HCD	varchar(50),
	CVF	int,
	dummy char(1)
);
copy MRHIER from '@filePath/MRHIER.RRF' with delimiter as '|' null as '';
alter table mrhier drop column dummy;

DROP TABLE MRHIST;
CREATE TABLE MRHIST (
	CUI	char(8) NOT NULL,
	SOURCEUI	varchar(50) NOT NULL,
	SAB	varchar(20) NOT NULL,
	SVER	varchar(20) NOT NULL,
	CHANGETYPE	text NOT NULL,
	CHANGEKEY	text NOT NULL,
	CHANGEVAL	text NOT NULL,
	REASON	text,
	CVF	int,
	dummy char(1)
);
copy MRHIST from '@filePath/MRHIST.RRF' with delimiter as '|' null as '';
alter table mrhist drop column dummy;

DROP TABLE MRMAP;
CREATE TABLE MRMAP (
	MAPSETCUI	char(8),
	MAPSETSAB	varchar(20),
	MAPSUBSETID	varchar(10),
	MAPRANK	int,
	MAPID	varchar(50),
	MAPSID	varchar(50),
	FROMID	varchar(50),
	FROMSID	varchar(50),
	FROMEXPR	text,
	FROMTYPE	varchar(50),
	FROMRULE	text,
	FROMRES	text,
	REL	varchar(4),
	RELA	varchar(100),
	TOID	varchar(50),
	TOSID	varchar(50),
	TOEXPR	text,
	TOTYPE	varchar(50),
	TORULE	text,
	TORES	text,
	MAPRULE	text,
	MAPRES	text,
	MAPTYPE	varchar(50),
	MAPATN	varchar(20),
	MAPATV	text,
	CVF	int,
	dummy char(1)
);
copy MRMAP from '@filePath/MRMAP.RRF' with delimiter as '|' null as '';
alter table mrmap drop column dummy;

DROP TABLE MRRANK;
CREATE TABLE MRRANK (
	RANK	int NOT NULL,
	SAB	varchar(20) NOT NULL,
	TTY	varchar(20) NOT NULL,
	SUPPRESS	char(1) NOT NULL,
	dummy char(1)
);
copy MRRANK from '@filePath/MRRANK.RRF' with delimiter as '|' null as '';
alter table mrrank drop column dummy;

DROP TABLE MRREL;
CREATE TABLE MRREL (
	CUI1	char(8) NOT NULL,
	AUI1	varchar(9),
	STYPE1	varchar(50) NOT NULL,
	REL	varchar(4) NOT NULL,
	CUI2	char(8) NOT NULL,
	AUI2	varchar(9),
	STYPE2	varchar(50) NOT NULL,
	RELA	varchar(100),
	RUI	varchar(10) NOT NULL,
	SRUI	varchar(50),
	SAB	varchar(20) NOT NULL,
	SL	varchar(20) NOT NULL,
	RG	varchar(10),
	DIR	varchar(1),
	SUPPRESS	char(1) NOT NULL,
	CVF	int,
	dummy char(1)
);
copy MRREL from '@filePath/MRREL.RRF' with delimiter as '|' null as '';
alter table mrrel drop column dummy;

DROP TABLE MRSAB;
CREATE TABLE MRSAB (
	VCUI	char(8),
	RCUI	char(8) NOT NULL,
	VSAB	varchar(20) NOT NULL,
	RSAB	varchar(20) NOT NULL,
	SON	text NOT NULL,
	SF	varchar(20) NOT NULL,
	SVER	varchar(20),
	VSTART	char(10),
	VEND	char(10),
	IMETA	varchar(10) NOT NULL,
	RMETA	varchar(10),
	SLC	text,
	SCC	text,
	SRL	int NOT NULL,
	TFR	int,
	CFR	int,
	CXTY	varchar(50),
	TTYL	varchar(200),
	ATNL	text,
	LAT	char(3),
	CENC	varchar(20) NOT NULL,
	CURVER	char(1) NOT NULL,
	SABIN	char(1) NOT NULL,
	SSN	text NOT NULL,
	SCIT	text NOT NULL,
	dummy char(1)
);
copy MRSAB from '@filePath/MRSAB.RRF' with delimiter as '|' null as '';
alter table mrsab drop column dummy;

DROP TABLE MRSAT;
CREATE TABLE MRSAT (
	CUI	char(8) NOT NULL,
	LUI	char(8),
	SUI	char(8),
	METAUI	varchar(50),
	STYPE	varchar(50) NOT NULL,
	CODE	varchar(50),
	ATUI	varchar(10) NOT NULL,
	SATUI	varchar(50),
	ATN	varchar(50) NOT NULL,
	SAB	varchar(20) NOT NULL,
	ATV	text,
	SUPPRESS	char(1) NOT NULL,
	CVF	int,
	dummy char(1)
);
copy MRSAT from '@filePath/MRSAT.RRF' with delimiter as '|' null as '';
alter table mrsat drop column dummy;

DROP TABLE MRSMAP;
CREATE TABLE MRSMAP (
	MAPSETCUI	char(8),
	MAPSETSAB	varchar(20),
	MAPID	varchar(50),
	MAPSID	varchar(50),
	FROMEXPR	text,
	FROMTYPE	varchar(50),
	REL	varchar(4),
	RELA	varchar(100),
	TOEXPR	text,
	TOTYPE	varchar(50),
	CVF	int,
	dummy char(1)
);
copy MRSMAP from '@filePath/MRSMAP.RRF' with delimiter as '|' null as '';
alter table mrsmap drop column dummy;

DROP TABLE MRSTY;
CREATE TABLE MRSTY (
	CUI	char(8) NOT NULL,
	TUI	char(4) NOT NULL,
	STN	varchar(100) NOT NULL,
	STY	varchar(50) NOT NULL,
	ATUI	varchar(10) NOT NULL,
	CVF	int,
	dummy char(1)
);
copy MRSTY from '@filePath/MRSTY.RRF' with delimiter as '|' null as '';
alter table mrsty drop column dummy;

DROP TABLE MRXNS_ENG;
CREATE TABLE MRXNS_ENG (
	LAT	char(3) NOT NULL,
	NSTR	text NOT NULL,
	CUI	char(8) NOT NULL,
	LUI	char(8) NOT NULL,
	SUI	char(8) NOT NULL,
	dummy char(1)
);
copy MRXNS_ENG from '@filePath/MRXNS_ENG.RRF' with delimiter as '|' null as '';
alter table mrxns_eng drop column dummy;

DROP TABLE MRXNW_ENG;
CREATE TABLE MRXNW_ENG (
	LAT	char(3) NOT NULL,
	NWD	varchar(100) NOT NULL,
	CUI	char(8) NOT NULL,
	LUI	char(8) NOT NULL,
	SUI	char(8) NOT NULL,
	dummy char(1)
);
copy MRXNW_ENG from '@filePath/MRXNW_ENG.RRF' with delimiter as '|' null as '';
alter table mrxnw_eng drop column dummy;

DROP TABLE MRAUI;
CREATE TABLE MRAUI (
	AUI1	varchar(9) NOT NULL,
	CUI1	char(8) NOT NULL,
	VER	varchar(10) NOT NULL,
	REL	varchar(4),
	RELA	varchar(100),
	MAPREASON	text NOT NULL,
	AUI2	varchar(9) NOT NULL,
	CUI2	char(8) NOT NULL,
	MAPIN	char(1) NOT NULL,
	dummy char(1)
);
copy MRAUI from '@filePath/MRAUI.RRF' with delimiter as '|' null as '';
alter table mraui drop column dummy;

DROP TABLE MRXW_BAQ;
CREATE TABLE MRXW_BAQ (
	LAT	char(3) NOT NULL,
	WD	varchar(100) NOT NULL,
	CUI	char(8) NOT NULL,
	LUI	char(8) NOT NULL,
	SUI	char(8) NOT NULL,
	dummy char(1)
);
copy MRXW_BAQ from '@filePath/MRXW_BAQ.RRF' with delimiter as '|' null as '';
alter table mrxw_baq drop column dummy;

DROP TABLE MRXW_CZE;
CREATE TABLE MRXW_CZE (
	LAT	char(3) NOT NULL,
	WD	varchar(100) NOT NULL,
	CUI	char(8) NOT NULL,
	LUI	char(8) NOT NULL,
	SUI	char(8) NOT NULL,
	dummy char(1)
);
copy MRXW_CZE from '@filePath/MRXW_CZE.RRF' with delimiter as '|' null as '';
alter table mrxw_cze drop column dummy;

DROP TABLE MRXW_DAN;
CREATE TABLE MRXW_DAN (
	LAT	char(3) NOT NULL,
	WD	varchar(100) NOT NULL,
	CUI	char(8) NOT NULL,
	LUI	char(8) NOT NULL,
	SUI	char(8) NOT NULL,
	dummy char(1)
);
copy MRXW_DAN from '@filePath/MRXW_DAN.RRF' with delimiter as '|' null as '';
alter table mrxw_dan drop column dummy;

DROP TABLE MRXW_DUT;
CREATE TABLE MRXW_DUT (
	LAT	char(3) NOT NULL,
	WD	varchar(100) NOT NULL,
	CUI	char(8) NOT NULL,
	LUI	char(8) NOT NULL,
	SUI	char(8) NOT NULL,
	dummy char(1)
);
copy MRXW_DUT from '@filePath/MRXW_DUT.RRF' with delimiter as '|' null as '';
alter table mrxw_dut drop column dummy;

DROP TABLE MRXW_ENG;
CREATE TABLE MRXW_ENG (
	LAT	char(3) NOT NULL,
	WD	varchar(100) NOT NULL,
	CUI	char(8) NOT NULL,
	LUI	char(8) NOT NULL,
	SUI	char(8) NOT NULL,
	dummy char(1)
);
copy MRXW_ENG from '@filePath/MRXW_ENG.RRF' with delimiter as '|' null as '';
alter table mrxw_eng drop column dummy;

DROP TABLE MRXW_FIN;
CREATE TABLE MRXW_FIN (
	LAT	char(3) NOT NULL,
	WD	varchar(100) NOT NULL,
	CUI	char(8) NOT NULL,
	LUI	char(8) NOT NULL,
	SUI	char(8) NOT NULL,
	dummy char(1)
);
copy MRXW_FIN from '@filePath/MRXW_FIN.RRF' with delimiter as '|' null as '';
alter table mrxw_fin drop column dummy;

DROP TABLE MRXW_FRE;
CREATE TABLE MRXW_FRE (
	LAT	char(3) NOT NULL,
	WD	varchar(100) NOT NULL,
	CUI	char(8) NOT NULL,
	LUI	char(8) NOT NULL,
	SUI	char(8) NOT NULL,
	dummy char(1)
);
copy MRXW_FRE from '@filePath/MRXW_FRE.RRF' with delimiter as '|' null as '';
alter table mrxw_fre drop column dummy;

DROP TABLE MRXW_GER;
CREATE TABLE MRXW_GER (
	LAT	char(3) NOT NULL,
	WD	varchar(100) NOT NULL,
	CUI	char(8) NOT NULL,
	LUI	char(8) NOT NULL,
	SUI	char(8) NOT NULL,
	dummy char(1)
);
copy MRXW_GER from '@filePath/MRXW_GER.RRF' with delimiter as '|' null as '';
alter table mrxw_ger drop column dummy;

DROP TABLE MRXW_HEB;
CREATE TABLE MRXW_HEB (
	LAT	char(3) NOT NULL,
	WD	varchar(100) NOT NULL,
	CUI	char(8) NOT NULL,
	LUI	char(8) NOT NULL,
	SUI	char(8) NOT NULL,
	dummy char(1)
);
copy MRXW_HEB from '@filePath/MRXW_HEB.RRF' with delimiter as '|' null as '';
alter table mrxw_heb drop column dummy;

DROP TABLE MRXW_HUN;
CREATE TABLE MRXW_HUN (
	LAT	char(3) NOT NULL,
	WD	varchar(100) NOT NULL,
	CUI	char(8) NOT NULL,
	LUI	char(8) NOT NULL,
	SUI	char(8) NOT NULL,
	dummy char(1)
);
copy MRXW_HUN from '@filePath/MRXW_HUN.RRF' with delimiter as '|' null as '';
alter table mrxw_hun drop column dummy;

DROP TABLE MRXW_ITA;
CREATE TABLE MRXW_ITA (
	LAT	char(3) NOT NULL,
	WD	varchar(100) NOT NULL,
	CUI	char(8) NOT NULL,
	LUI	char(8) NOT NULL,
	SUI	char(8) NOT NULL,
	dummy char(1)
);
copy MRXW_ITA from '@filePath/MRXW_ITA.RRF' with delimiter as '|' null as '';
alter table mrxw_ita drop column dummy;

DROP TABLE MRXW_JPN;
CREATE TABLE MRXW_JPN (
	LAT	char(3) NOT NULL,
	WD	varchar(100) NOT NULL,
	CUI	char(8) NOT NULL,
	LUI	char(8) NOT NULL,
	SUI	char(8) NOT NULL,
	dummy char(1)
);
copy MRXW_JPN from '@filePath/MRXW_JPN.RRF' with delimiter as '|' null as '';
alter table mrxw_jpn drop column dummy;

DROP TABLE MRXW_NOR;
CREATE TABLE MRXW_NOR (
	LAT	char(3) NOT NULL,
	WD	varchar(100) NOT NULL,
	CUI	char(8) NOT NULL,
	LUI	char(8) NOT NULL,
	SUI	char(8) NOT NULL,
	dummy char(1)
);
copy MRXW_NOR from '@filePath/MRXW_NOR.RRF' with delimiter as '|' null as '';
alter table mrxw_nor drop column dummy;

DROP TABLE MRXW_POR;
CREATE TABLE MRXW_POR (
	LAT	char(3) NOT NULL,
	WD	varchar(100) NOT NULL,
	CUI	char(8) NOT NULL,
	LUI	char(8) NOT NULL,
	SUI	char(8) NOT NULL,
	dummy char(1)
);
copy MRXW_POR from '@filePath/MRXW_POR.RRF' with delimiter as '|' null as '';
alter table mrxw_por drop column dummy;

DROP TABLE MRXW_RUS;
CREATE TABLE MRXW_RUS (
	LAT	char(3) NOT NULL,
	WD	varchar(100) NOT NULL,
	CUI	char(8) NOT NULL,
	LUI	char(8) NOT NULL,
	SUI	char(8) NOT NULL,
	dummy char(1)
);
copy MRXW_RUS from '@filePath/MRXW_RUS.RRF' with delimiter as '|' null as '';
alter table mrxw_rus drop column dummy;

DROP TABLE MRXW_SPA;
CREATE TABLE MRXW_SPA (
	LAT	char(3) NOT NULL,
	WD	varchar(100) NOT NULL,
	CUI	char(8) NOT NULL,
	LUI	char(8) NOT NULL,
	SUI	char(8) NOT NULL,
	dummy char(1)
);
copy MRXW_SPA from '@filePath/MRXW_SPA.RRF' with delimiter as '|' null as '';
alter table mrxw_spa drop column dummy;

DROP TABLE MRXW_SWE;
CREATE TABLE MRXW_SWE (
	LAT	char(3) NOT NULL,
	WD	varchar(100) NOT NULL,
	CUI	char(8) NOT NULL,
	LUI	char(8) NOT NULL,
	SUI	char(8) NOT NULL,
	dummy char(1)
);
copy MRXW_SWE from '@filePath/MRXW_SWE.RRF' with delimiter as '|' null as '';
alter table mrxw_swe drop column dummy;

DROP TABLE AMBIGSUI;
CREATE TABLE AMBIGSUI (
	SUI	char(8) NOT NULL,
	CUI	char(8) NOT NULL,
	dummy char(1)
);
copy AMBIGSUI from '@filePath/AMBIGSUI.RRF' with delimiter as '|' null as '';
alter table ambigsui drop column dummy;

DROP TABLE AMBIGLUI;
CREATE TABLE AMBIGLUI (
	LUI	char(8) NOT NULL,
	CUI	char(8) NOT NULL,
	dummy char(1)
);
copy AMBIGLUI from '@filePath/AMBIGLUI.RRF' with delimiter as '|' null as '';
alter table ambiglui drop column dummy;

DROP TABLE DELETEDCUI;
CREATE TABLE DELETEDCUI (
	PCUI	char(8) NOT NULL,
	PSTR	text NOT NULL,
	dummy char(1)
);
copy DELETEDCUI from '@filePath/DELETEDCUI.RRF' with delimiter as '|' null as '';
alter table deletedcui drop column dummy;

DROP TABLE DELETEDLUI;
CREATE TABLE DELETEDLUI (
	PLUI	char(8) NOT NULL,
	PSTR	text NOT NULL,
	dummy char(1)
);
copy DELETEDLUI from '@filePath/DELETEDLUI.RRF' with delimiter as '|' null as '';
alter table deletedlui drop column dummy;

DROP TABLE DELETEDSUI;
CREATE TABLE DELETEDSUI (
	PSUI	char(8) NOT NULL,
	LAT	char(3) NOT NULL,
	PSTR	text NOT NULL,
	dummy char(1)
);
copy DELETEDSUI from '@filePath/DELETEDSUI.RRF' with delimiter as '|' null as '';
alter table deletedsui drop column dummy;

DROP TABLE MERGEDCUI;
CREATE TABLE MERGEDCUI (
	PCUI	char(8) NOT NULL,
	CUI	char(8) NOT NULL,
	dummy char(1)
);
copy MERGEDCUI from '@filePath/MERGEDCUI.RRF' with delimiter as '|' null as '';
alter table mergedcui drop column dummy;

DROP TABLE MERGEDLUI;
CREATE TABLE MERGEDLUI (
	PLUI	char(8),
	LUI	char(8),
	dummy char(1)
);
copy MERGEDLUI from '@filePath/MERGEDLUI.RRF' with delimiter as '|' null as '';
alter table mergedlui drop column dummy;

