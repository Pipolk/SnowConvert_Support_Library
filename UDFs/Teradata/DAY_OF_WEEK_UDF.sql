-- <copyright file="DAY_OF_WEEK_UDF.sql" company="Mobilize.Net">
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
-- RETURNS THE DAY OF THE WEEK A TIMESTAMP BELONGS TO, HAS THE SAME BEHAVIOR AS THE TD_DAY_OF WEEK FUNCTION FROM TERADATA
-- PARAMETERS:
--      INPUT: TIMESTAMP_TZ. DATE TO GET THE DAY OF WEEK FROM
-- RETURNS:
--      AN INTEGER BETWEEN 1 AND 7 WHERE 1 = SUNDAY, 2 = MONDAY, ..., 7 = SATURDAY
-- ======================================================================
CREATE OR REPLACE FUNCTION PUBLIC.TD_DAY_OF_WEEK_UDF(INPUT TIMESTAMP_TZ)
RETURNS INT
LANGUAGE SQL
IMMUTABLE
AS
$$
    IFF(DAYOFWEEKISO(INPUT) = 7, 1, DAYOFWEEKISO(INPUT) + 1)
$$;