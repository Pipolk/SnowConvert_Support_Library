-- <copyright file="QUARTER_OF_YEAR_ISO_UDF.sql" company="Mobilize.Net">
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

-- ======================================================================
-- DESCRIPTION: UDF THAT REPRODUCES TERADATA'S QUARTERNUMBER_OF_YEAR(Date,'ISO') FUNCTIONALITY
-- PARAMETERS:
--      INPUT: TIMESTAMP_TZ. DATE TO GET THE NUMBER OF QUARTER FROM
-- RETURNS:
--      AN INTEGER THAT REPRESENTS THE QUARTER THE DATE BELONGS TO
--
-- EXAMPLE:
--  SELECT PUBLIC.QUARTER_OF_YEAR_ISO_UDF(DATE '2022-01-01'),
--  PUBLIC.QUARTER_OF_YEAR_ISO_UDF(DATE '2025-12-31');
-- RETURNS 4, 1
--
-- EQUIVALENT: TERADATA'S QUARTERNUMBER_OF_YEAR FUNCTIONALITY
-- EXAMPLE:
--  SELECT QUARTERNUMBER_OF_YEAR(DATE '2022-01-01', 'ISO'),
--  QUARTERNUMBER_OF_YEAR(DATE '2025-12-31', 'ISO');
-- RETURNS 4, 1
-- ======================================================================
CREATE OR REPLACE FUNCTION PUBLIC.QUARTER_OF_YEAR_ISO_UDF(INPUT TIMESTAMP_TZ)
RETURNS INT
LANGUAGE SQL
IMMUTABLE
AS
$$
    CASE
        WHEN WEEKISO(INPUT)<=13 THEN 1
        WHEN WEEKISO(INPUT)<=26 THEN 2
        WHEN WEEKISO(INPUT)<=39 THEN 3
        ELSE 4
    END
$$;