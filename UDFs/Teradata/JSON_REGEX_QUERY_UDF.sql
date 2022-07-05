-- <copyright file="JSON_REGEX_QUERY_UDF.sql" company="Mobilize.Net">
--        Copyright (C) Mobilize.Net info@mobilize.net - All Rights Reserved
-- 
--        This file is part of the Mobilize Frameworks, which is
--        proprietary and confidential.
-- 
--        NOTICE:  All information contained herein is, and remains
--        the property of Mobilize.Net Corporation.
--        The intellectual and technical concepts contained herein are
--        proprietary to Mobilize.Net Corporation and may be covered
--        by U.S. Patents, and are protected by trade secret or copyright law.
--        Dissemination of this information or reproduction of this material
--        is strictly forbidden unless prior written permission is obtained
--        from Mobilize.Net Corporation.
-- </copyright>

-- =============================================
-- DESCRIPTION: UDF THAT REPRODUCES TERADATA'S JSON ENTITY REFERENCE (DOT NOTATION SYNTAX) FUNCTIONALITY
-- EQUIVALENT: TERADATA'S JSON ENTITY REFERENCE (DOT NOTATION SYNTAX) FUNCTIONALITY
-- PARAMETERS:
--  JSON_DATA: VARIANT
--  REGEX_PATH: VARCHAR
-- RETURNS: FILTERED JSON DATA
-- EXAMPLE:
--  SELECT PUBLIC.JSON_REGEX_QUERY_UDF(PARSE_JSON('{"name" : {"schools" : {"name1" : "Lake", "type" : "elementary"}}, "age" : 25, 
--  "schools" : [ {"name1" : "Lake", "type" : "elementary"}, 
--  {"name" : "Madison", "type" : "middle"}, 
--  {"name" : "Rancho", "type" : "high"} ], 
--  "job" : "small business owner"}'), '.*schools(\\[(1|2)\\]|(\\.name1))')
--  RETURNS [ "Lake", { "name": "Madison", "type": "middle" }, { "name": "Rancho", "type": "high" } ]
--
-- TERADATA EQUIVALENT: JSON Entity Reference (Dot Notation Syntax) 
-- EXAMPLE:
--   SELECT CAST('{"name" : {"schools" : {"name1" : "Lake", "type" : "elementary"}}, "age" : 25, 
--   "schools" : [ {"name1" : "Lake", "type" : "elementary"}, 
--   {"name" : "Madison", "type" : "middle"}, 
--   {"name" : "Rancho", "type" : "high"} ], 
--   "job" : "small business owner"}' AS JSON(3000))..schools[1,2,name1];
--  RETURNS [{"name":"Madison","type":"middle"},{"name":"Rancho","type":"high"},"Lake"]
--
-- =============================================
CREATE OR REPLACE FUNCTION PUBLIC.JSON_REGEX_QUERY_UDF(JSON_DATA VARIANT, REGEX_PATH VARCHAR)
RETURNS VARIANT
IMMUTABLE
AS
$$
SELECT PARSE_JSON(SELECT '[' || listagg( IFF( IS_VARCHAR( jt.value ) , '"'|| jt.value ||'"' , jt.value ) , ', ') || ']' 
FROM TABLE(FLATTEN(input => JSON_DATA , RECURSIVE => TRUE)) jt
WHERE  RLIKE(jt.path, REGEX_PATH) )
$$;
