-- <copyright file="TZ_OFFSET_UDF.sql" company="Mobilize.Net">
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
-- This functions emulates the behavior of the oracle function [TZ_OFFSET](https://docs.oracle.com/cd/B19306_01/server.102/b14200/functions202.htm)
-- =============================================

-- =============================================
-- Description: Emulates the behavior of the TZ_OFFSET function in Oracle
-- The input parameter should be a VARCHAR with an string or a TIMESTAMP
-- The output will be the string with the time zone offset corresponding to the argument
-- Example:
-- Input:
-- In Oracle:
-- select TZ_OFFSET('US/Michigan') from dual; -- Result: '-05:00'
-- select TZ_OFFSET('-08:00') from dual; -- Result: '-08:00'
-- select TZ_OFFSET(sessiontimezone) from dual; -- Result: '-07:00'  (depending on your configuration)
-- SELECT TZ_OFFSET(dbtimezone) FROM DUAL; -- Result: '+00:00'  (depending on your configuration)
-- In Snowflake
-- select TZ_OFFSET('US/Michigan') from dual; -- Result: '-05:00'
-- select TZ_OFFSET('-08:00') from dual; -- Result: '-08:00'
-- select TZ_OFFSET(current_timestamp()) from dual; -- Result: '-07:00'  (depending on your configuration)
-- SELECT TZ_OFFSET(sysdate()) FROM DUAL; -- Result: '+00:00'  (depending on your configuration)
-- =============================================
--  Credit for this UDF goes to Marco Carrillo
CREATE OR REPLACE FUNCTION PUBLIC.TZ_OFFSET_UDF (TIMEZONE VARCHAR)
RETURNS STRING
IMMUTABLE
AS
$$
    SELECT
    CASE 
        WHEN SUBSTRING(TIMEZONE,1,1) IN ('+','-') THEN TIMEZONE
        ELSE to_varchar(DATE_PART(tzh,CONVERT_TIMEZONE(TIMEZONE,CURRENT_TIMESTAMP)), 'S09')||':00'
    END TZ_OFFSET
$$;

CREATE OR REPLACE FUNCTION PUBLIC.TZ_OFFSET_UDF (TIMEZONE TIMESTAMP_TZ)
RETURNS STRING
AS
$$
    SELECT to_varchar(DATE_PART(tzh,TIMEZONE), 'S09')||':00' TZ_OFFSET
$$;
