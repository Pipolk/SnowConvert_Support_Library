-- <copyright file="CHKNUM_UDF.sql" company="Mobilize.Net">
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
-- DESCRIPTION: CHECKS IF A STRING VALUE REPRESENT A NUMERIC VALUE
-- PARAMETER: STRING VALUE
-- RETURNS: RETURNS 1 IF THE PARAMETERS IS A VALID NUMBER 
-- EXAMPLE:
--    SELECT CHKNUM_UDF('432');
--    RETURNS 1
-- TERADATA EQUIVALENT: CHKNUM function (it is a teradata extension)
-- EXAMPLE:
--    SELECT CHKNUM('432');
--    RETURNS 1
-- =============================================
CREATE OR REPLACE FUNCTION PUBLIC.CHKNUM_UDF(NUM STRING)
RETURNS INTEGER
AS
$$
IFF(TRY_CAST(NUM AS NUMBER) IS NOT NULL,1,0)
$$;
