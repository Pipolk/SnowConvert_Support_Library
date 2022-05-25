-- <copyright file="INTERVAL_UDF.sql" company="Mobilize.Net">
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
-- Description: UDF for Teradata INTERVAL_MULTIPLY function
-- =============================================
CREATE OR REPLACE FUNCTION PUBLIC.INTERVAL_MULTIPLY_UDF
(INPUT_PART VARCHAR(30), INPUT_VALUE VARCHAR(), INPUT_MULT INTEGER)
RETURNS VARCHAR
IMMUTABLE
AS
$$
CASE WHEN INPUT_PART = 'YEAR TO MONTH'
THEN PUBLIC.MONTHS2INTERVAL_UDF(INPUT_PART, PUBLIC.INTERVAL2MONTHS_UDF(INPUT_VALUE) * INPUT_MULT)
ELSE PUBLIC.SECONDS2INTERVAL_UDF(INPUT_PART, PUBLIC.INTERVAL2SECONDS_UDF(INPUT_PART, INPUT_VALUE) * INPUT_MULT)
END
$$;

-- =============================================
-- Description: UDF for Teradata INTERVAL_ADD function
-- =============================================
CREATE OR REPLACE FUNCTION PUBLIC.INTERVAL_ADD_UDF
(INPUT_VALUE1 VARCHAR(), INPUT_PART1 VARCHAR(30), INPUT_VALUE2 VARCHAR(), INPUT_PART2 VARCHAR(30), OP CHAR, OUTPUT_PART VARCHAR())
RETURNS VARCHAR
IMMUTABLE
AS
$$
CASE 
    WHEN INPUT_PART1 = 'YEAR TO MONTH' OR INPUT_PART2 = 'YEAR TO MONTH' THEN
        CASE 
            WHEN OP = '+' THEN
                PUBLIC.SECONDS2INTERVAL_UDF(OUTPUT_PART, PUBLIC.INTERVAL2MONTHS_UDF(INPUT_VALUE1) + PUBLIC.INTERVAL2MONTHS_UDF(INPUT_VALUE2))
            WHEN OP = '-' THEN
                PUBLIC.SECONDS2INTERVAL_UDF(OUTPUT_PART, PUBLIC.INTERVAL2MONTHS_UDF(INPUT_VALUE1) - PUBLIC.INTERVAL2MONTHS_UDF(INPUT_VALUE2))
        END
    ELSE 
        CASE 
            WHEN OP = '+' THEN
                PUBLIC.SECONDS2INTERVAL_UDF(OUTPUT_PART, PUBLIC.INTERVAL2SECONDS_UDF(INPUT_PART1, INPUT_VALUE1) + PUBLIC.INTERVAL2SECONDS_UDF(INPUT_PART2, INPUT_VALUE2))
            WHEN OP = '-' THEN
                PUBLIC.SECONDS2INTERVAL_UDF(OUTPUT_PART, PUBLIC.INTERVAL2SECONDS_UDF(INPUT_PART1, INPUT_VALUE1) - PUBLIC.INTERVAL2SECONDS_UDF(INPUT_PART2, INPUT_VALUE2))
        END  
END
$$;

-- =============================================
-- Description: UDF for converting an Interval to Months
-- =============================================
CREATE OR REPLACE FUNCTION PUBLIC.INTERVAL2MONTHS_UDF
(INPUT_VALUE VARCHAR())
RETURNS INTEGER
IMMUTABLE
AS
$$
CASE WHEN SUBSTR(INPUT_VALUE,1,1) = '-' THEN
   12 * CAST(SUBSTR(INPUT_VALUE,1 , POSITION('-', INPUT_VALUE,2)-1) AS INTEGER)
   - CAST(SUBSTR(INPUT_VALUE,POSITION('-', INPUT_VALUE)+1) AS INTEGER)
ELSE
   12 * CAST(SUBSTR(INPUT_VALUE,1 , POSITION('-', INPUT_VALUE,2)-1) AS INTEGER)
   + CAST(SUBSTR(INPUT_VALUE,POSITION('-', INPUT_VALUE)+1) AS INTEGER)
END
$$;

-- =============================================
-- Description: UDF for converting an Interval to Seconds
-- =============================================
CREATE OR REPLACE FUNCTION PUBLIC.INTERVAL2SECONDS_UDF
(INPUT_PART VARCHAR(30), INPUT_VALUE VARCHAR())
RETURNS DECIMAL(20,6)
IMMUTABLE
AS
$$
CASE WHEN SUBSTR(INPUT_VALUE,1,1) = '-' THEN
   DECODE(INPUT_PART,
           'DAY',              86400 * INPUT_VALUE, 
           'DAY TO HOUR',      86400 * CAST(SUBSTR(INPUT_VALUE, 1, POSITION(' ', INPUT_VALUE)-1) AS DECIMAL(10,0)) 
                               - 3600 * CAST(SUBSTR(INPUT_VALUE, POSITION(' ', INPUT_VALUE)+1) AS DECIMAL(10,0)),
           'DAY TO MINUTE',    86400 * CAST(SUBSTR(INPUT_VALUE, 1, POSITION(' ', INPUT_VALUE)-1) AS INTEGER) 
                               - 3600 * CAST(SUBSTR(INPUT_VALUE, POSITION(' ', INPUT_VALUE)+1, POSITION(':', INPUT_VALUE)-POSITION(' ', INPUT_VALUE)-1) AS INTEGER) 
                               - 60 * CAST(SUBSTR(INPUT_VALUE, POSITION(':', INPUT_VALUE)+1) AS INTEGER),
           'DAY TO SECOND',    86400 * CAST(SUBSTR(INPUT_VALUE, 1, POSITION(' ', INPUT_VALUE)-1) AS INTEGER) 
                               - 3600 * CAST(SUBSTR(INPUT_VALUE, POSITION(' ', INPUT_VALUE)+1, POSITION(':', INPUT_VALUE)-POSITION(' ', INPUT_VALUE)-1) AS INTEGER)
                               - 60 * CAST(SUBSTR(INPUT_VALUE, POSITION(':', INPUT_VALUE)+1, POSITION(':', INPUT_VALUE, POSITION(':', INPUT_VALUE)+1) - POSITION(':', INPUT_VALUE) - 1) AS INTEGER)
                               - CAST(SUBSTR(INPUT_VALUE,POSITION(':', INPUT_VALUE, POSITION(':', INPUT_VALUE)+1)+1) AS DECIMAL(10,6)),
           'HOUR',             3600 * INPUT_VALUE, 
           'HOUR TO MINUTE',   3600 * CAST(SUBSTR(INPUT_VALUE,1 , POSITION(':', INPUT_VALUE)-1) AS INTEGER)
                               - 60 * CAST(SUBSTR(INPUT_VALUE,POSITION(':', INPUT_VALUE)+1) AS INTEGER),
           'HOUR TO SECOND',   3600 * CAST(SUBSTR(INPUT_VALUE, 1, POSITION(':', INPUT_VALUE)-POSITION(' ', INPUT_VALUE)-1) AS INTEGER)
                               - 60 * CAST(SUBSTR(INPUT_VALUE, POSITION(':', INPUT_VALUE)+1, POSITION(':', INPUT_VALUE, POSITION(':', INPUT_VALUE)+1) - POSITION(':', INPUT_VALUE) - 1) AS INTEGER)
                               - CAST(SUBSTR(INPUT_VALUE,POSITION(':', INPUT_VALUE, POSITION(':', INPUT_VALUE)+1)+1) AS DECIMAL(10,6)),  
           'MINUTE',           60 * INPUT_VALUE,     
           'MINUTE TO SECOND', 60 * CAST(SUBSTR(INPUT_VALUE, 1, POSITION(':', INPUT_VALUE)-POSITION(' ', INPUT_VALUE)-1) AS INTEGER)
                               - CAST(SUBSTR(INPUT_VALUE, POSITION(':', INPUT_VALUE)+1) AS DECIMAL(10,6)),
           'SECOND',           INPUT_VALUE                                    
            )
ELSE
   DECODE(INPUT_PART,
           'DAY',              86400 * INPUT_VALUE, 
           'DAY TO HOUR',      86400 * CAST(SUBSTR(INPUT_VALUE, 1, POSITION(' ', INPUT_VALUE)-1) AS INTEGER) 
                               + 3600 * CAST(SUBSTR(INPUT_VALUE, POSITION(' ', INPUT_VALUE)+1) AS INTEGER),
           'DAY TO MINUTE',    86400 * CAST(SUBSTR(INPUT_VALUE, 1, POSITION(' ', INPUT_VALUE)-1) AS INTEGER) 
                               + 3600 * CAST(SUBSTR(INPUT_VALUE, POSITION(' ', INPUT_VALUE)+1, POSITION(':', INPUT_VALUE)-POSITION(' ', INPUT_VALUE)-1) AS INTEGER) 
                               + 60 * CAST(SUBSTR(INPUT_VALUE, POSITION(':', INPUT_VALUE)+1) AS INTEGER),
           'DAY TO SECOND',    86400 * CAST(SUBSTR(INPUT_VALUE, 1, POSITION(' ', INPUT_VALUE)-1) AS INTEGER) 
                               + 3600 * CAST(SUBSTR(INPUT_VALUE, POSITION(' ', INPUT_VALUE)+1, POSITION(':', INPUT_VALUE)-POSITION(' ', INPUT_VALUE)-1) AS INTEGER)
                               + 60 * CAST(SUBSTR(INPUT_VALUE, POSITION(':', INPUT_VALUE)+1, POSITION(':', INPUT_VALUE, POSITION(':', INPUT_VALUE)+1) - POSITION(':', INPUT_VALUE) - 1) AS INTEGER)
                               + CAST(SUBSTR(INPUT_VALUE,POSITION(':', INPUT_VALUE, POSITION(':', INPUT_VALUE)+1)+1) AS DECIMAL(10,6)),
           'HOUR',             3600 * INPUT_VALUE, 
           'HOUR TO MINUTE',   3600 * CAST(SUBSTR(INPUT_VALUE,1 , POSITION(':', INPUT_VALUE)-1) AS INTEGER)
                               + 60 * CAST(SUBSTR(INPUT_VALUE,POSITION(':', INPUT_VALUE)+1) AS INTEGER),
           'HOUR TO SECOND',   3600 * CAST(SUBSTR(INPUT_VALUE, 1, POSITION(':', INPUT_VALUE)-POSITION(' ', INPUT_VALUE)-1) AS INTEGER)
                               + 60 * CAST(SUBSTR(INPUT_VALUE, POSITION(':', INPUT_VALUE)+1, POSITION(':', INPUT_VALUE, POSITION(':', INPUT_VALUE)+1) - POSITION(':', INPUT_VALUE) - 1) AS INTEGER)
                               + CAST(SUBSTR(INPUT_VALUE,POSITION(':', INPUT_VALUE, POSITION(':', INPUT_VALUE)+1)+1) AS DECIMAL(10,6)),  
           'MINUTE',           60 * INPUT_VALUE,     
           'MINUTE TO SECOND', 60 * CAST(SUBSTR(INPUT_VALUE, 1, POSITION(':', INPUT_VALUE)-POSITION(' ', INPUT_VALUE)-1) AS INTEGER)
                               + CAST(SUBSTR(INPUT_VALUE, POSITION(':', INPUT_VALUE)+1) AS DECIMAL(10,6)), 
           'SECOND',           INPUT_VALUE                                    
        )
END
$$;

-- =============================================
-- Description: UDF for converting Months to an Interval
-- =============================================
CREATE OR REPLACE FUNCTION PUBLIC.MONTHS2INTERVAL_UDF
(INPUT_PART VARCHAR(30), INPUT_VALUE NUMBER)
RETURNS VARCHAR
IMMUTABLE
AS
$$
DECODE(INPUT_PART,
                'YEAR',                (INPUT_VALUE/(12))::varchar,
                'YEAR TO MONTH',       TRUNC(INPUT_VALUE / 12) ||'-'|| MOD(INPUT_VALUE, 12)::varchar,     
                'MONTH',               INPUT_VALUE::varchar
)
$$;

-- =============================================
-- Description: UDF for converting Seconds to an Interval
-- =============================================
CREATE OR REPLACE FUNCTION PUBLIC.SECONDS2INTERVAL_UDF
(INPUT_PART VARCHAR(30), INPUT_VALUE NUMBER)
RETURNS VARCHAR
IMMUTABLE
AS
$$
DECODE(INPUT_PART,
                'DAY',                TRUNC((INPUT_VALUE/(86400)))::varchar,
                'DAY TO HOUR',        TRUNC(INPUT_VALUE/(86400))::varchar || ' ' || 
                                            CASE 
                                                WHEN ABS(TRUNC(MOD(INPUT_VALUE,86400)/3600)) = 0 THEN '00' 
                                                WHEN ABS(TRUNC(MOD(INPUT_VALUE,86400)/3600)) > -10 AND ABS(TRUNC(MOD(INPUT_VALUE,86400)/3600)) < 10 THEN '0' ELSE '' END || 
                                            ABS(TRUNC(MOD(INPUT_VALUE,86400)/3600))::varchar,
                'DAY TO MINUTE',      TRUNC(INPUT_VALUE/(86400))::varchar || ' ' || 
                                            CASE 
                                                WHEN ABS(TRUNC(MOD(INPUT_VALUE,86400)/3600)) = 0 THEN '00' 
                                                WHEN ABS(TRUNC(MOD(INPUT_VALUE,86400)/3600)) > -10 AND ABS(TRUNC(MOD(INPUT_VALUE,86400)/3600)) < 10 THEN '0' ELSE '' END || 
                                            ABS(TRUNC(MOD(INPUT_VALUE,86400)/3600))::varchar || ':' || 
                                                CASE 
                                                    WHEN ABS(TRUNC(MOD(INPUT_VALUE, 3600)/60)) = 0 THEN '00' 
                                                    WHEN ABS(TRUNC(MOD(INPUT_VALUE, 3600)/60)) > -10 AND ABS(TRUNC(MOD(INPUT_VALUE, 3600)/60)) < 10 THEN '0' ELSE '' END || 
                                                ABS(TRUNC(MOD(INPUT_VALUE, 3600)/60))::varchar,
                'DAY TO SECOND',      TRUNC(INPUT_VALUE/(86400))::varchar || ' ' || 
                                            CASE 
                                                WHEN ABS(TRUNC(MOD(INPUT_VALUE,86400)/3600)) = 0 THEN '00' 
                                                WHEN ABS(TRUNC(MOD(INPUT_VALUE,86400)/3600)) > -10 AND ABS(TRUNC(MOD(INPUT_VALUE,86400)/3600)) < 10 THEN '0' ELSE '' END || 
                                            ABS(TRUNC(MOD(INPUT_VALUE,86400)/3600))::varchar || ':' || 
                                                CASE 
                                                    WHEN ABS(TRUNC(MOD(INPUT_VALUE, 3600)/60)) = 0 THEN '00' 
                                                    WHEN ABS(TRUNC(MOD(INPUT_VALUE, 3600)/60)) > -10 AND ABS(TRUNC(MOD(INPUT_VALUE, 3600)/60)) < 10 THEN '0' ELSE '' END || 
                                               ABS(TRUNC(MOD(INPUT_VALUE, 3600)/60)) || ':' ||
                                                    CASE 
                                                        WHEN ABS(MOD(INPUT_VALUE, 60)) = 0 THEN '00' 
                                                        WHEN ABS(MOD(INPUT_VALUE, 60)) > -10 AND ABS(MOD(INPUT_VALUE, 60)) < 10 THEN '0' ELSE '' END || 
                                                    ABS(MOD(INPUT_VALUE, 60))::varchar,
                'HOUR',               TRUNC((INPUT_VALUE/3600))::varchar,     
                'HOUR TO MINUTE',     TRUNC(INPUT_VALUE/3600)::varchar || ':' || 
                                            CASE 
                                                WHEN ABS(TRUNC(MOD(INPUT_VALUE, 3600)/60)) = 0 THEN '00' 
                                                WHEN ABS(TRUNC(MOD(INPUT_VALUE, 3600)/60)) > -10 AND ABS(TRUNC(MOD(INPUT_VALUE, 3600)/60)) < 10 THEN '0' ELSE '' END || 
                                             ABS(TRUNC(MOD(INPUT_VALUE, 3600)/60))::varchar,
                'HOUR TO SECOND',     TRUNC(INPUT_VALUE/3600)::varchar || ':' || 
                                            CASE WHEN ABS(TRUNC(MOD(INPUT_VALUE, 3600)/60)) = 0 THEN '00' WHEN ABS(TRUNC(MOD(INPUT_VALUE, 3600)/60)) > -10 AND ABS(TRUNC(MOD(INPUT_VALUE, 3600)/60)) < 10 THEN '0' ELSE '' END || ABS(TRUNC(MOD(INPUT_VALUE, 3600)/60)) || ':' ||
                                                CASE WHEN ABS(MOD(INPUT_VALUE, 60)) = 0 THEN '00' WHEN ABS(MOD(INPUT_VALUE, 60)) > -10 AND ABS(MOD(INPUT_VALUE, 60)) < 10 THEN '0' ELSE '' END || ABS(MOD(INPUT_VALUE, 60))::varchar,
                'MINUTE',             TRUNC((INPUT_VALUE/60))::varchar,                
                'MINUTE TO SECOND',   TRUNC(INPUT_VALUE/60)::varchar || ':' || 
                                            CASE WHEN ABS(MOD(INPUT_VALUE, 60)) = 0 THEN '00' WHEN ABS(MOD(INPUT_VALUE, 60)) > -10 AND ABS(MOD(INPUT_VALUE, 60)) < 10 THEN '0' ELSE '' END || ABS(MOD(INPUT_VALUE, 60))::varchar,
                'SECOND',             INPUT_VALUE::varchar
)
$$;




