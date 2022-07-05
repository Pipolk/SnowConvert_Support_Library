-- <copyright file="DATE_DIFFERENCE_UDF.sql" company="Mobilize.Net">
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
-- DESCRIPTION: UDF THAT REPRODUCES DATETIME TERADATA'S SUBTRACTION
-- PARAMETERS:
--  MINUEND: TIMESTAMP - DATE SUBTRACTED FROM
--  SUBTRAHEND: TIMESTAMP - DATE SUBTRACTED
--  INPUT_PART: VARCHAR - PARTS TO BE RETURNED (EQUIVALENT TO TERADATA'S INTERVAL)
-- RETURNS: FORMATED VARCHAR WITH INPUT_PART REQUESTED 
-- =============================================
CREATE OR REPLACE FUNCTION PUBLIC.TIMESTAMP_DIFFERENCE_UDF
(MINUEND TIMESTAMP, SUBTRAHEND TIMESTAMP, INPUT_PART VARCHAR)
RETURNS VARCHAR 
IMMUTABLE
AS
$$
   DECODE(INPUT_PART,
           'YEAR',             TO_VARCHAR(DATEDIFF(YEAR, SUBTRAHEND, MINUEND)),
           'DAY',              TO_VARCHAR(TRUNC(DATEDIFF(SECONDS, SUBTRAHEND, MINUEND)/(86400))),
           'DAY TO HOUR',      TO_VARCHAR(TRUNC(DATEDIFF(SECONDS, SUBTRAHEND, MINUEND)/(86400))) || ' ' || TIMEDIFF('HOUR', LEAST(MINUEND,SUBTRAHEND), GREATEST(MINUEND, SUBTRAHEND)),
           'DAY TO MINUTE',    TO_VARCHAR(TRUNC(DATEDIFF(SECONDS, SUBTRAHEND, MINUEND)/(86400))) || ' ' || TIMEDIFF('MINUTE', LEAST(MINUEND,SUBTRAHEND), GREATEST(MINUEND, SUBTRAHEND)),
           'DAY TO SECOND',    TO_VARCHAR(TRUNC(DATEDIFF(SECONDS, SUBTRAHEND, MINUEND)/(86400))) || ' ' || TIMEDIFF('SECOND', LEAST(MINUEND,SUBTRAHEND), GREATEST(MINUEND, SUBTRAHEND)),
           'HOUR',             TO_VARCHAR(DATEDIFF(HOUR, SUBTRAHEND, MINUEND)),
           'HOUR TO MINUTE',   TO_VARCHAR(DATEDIFF(HOUR, SUBTRAHEND, MINUEND)) || ':' || SPLIT_PART(TIMEDIFF('MINUTE', LEAST(MINUEND,SUBTRAHEND), GREATEST(MINUEND, SUBTRAHEND)), ':', 2),
           'HOUR TO SECOND',   TO_VARCHAR(DATEDIFF(HOUR, SUBTRAHEND, MINUEND)) || ':' || SUBSTR(TIMEDIFF('SECOND', LEAST(MINUEND,SUBTRAHEND), GREATEST(MINUEND, SUBTRAHEND)), -5),
           'MINUTE',           TO_VARCHAR(DATEDIFF(MINUTE, SUBTRAHEND, MINUEND)),
           'MINUTE TO SECOND', TO_VARCHAR( TRUNC(DATEDIFF(SECONDS, SUBTRAHEND, MINUEND)/60), 'FM9900') || ':' || SUBSTR(TIMEDIFF('SECOND', LEAST(MINUEND,SUBTRAHEND), GREATEST(MINUEND, SUBTRAHEND)), -2),
           'SECOND',           TO_VARCHAR(DATEDIFF(SECOND, SUBTRAHEND, MINUEND), '9999')
            )
$$;


-- =============================================
-- DESCRIPTION: UDF THAT REPRODUCE EXTRACT 'DATE PART' FROM 'DATE TIME' SUBTRACTION
-- PARAMETERS:
--  INTERVAL_DATA VARCHAR - FORMATED VARCHAR RETURNED BY TIMESTAMP_DIFFERENCE
--  INPUT_PART VARCHAR - ORIGINAL REQUESTED PART (SAME AS TIMESTAMP_DIFFERENCE INPUT_PART)
--  REQUEST_PART VARCHAR - EXTRACT PART
-- RETURN: NUMBER OF REQUEST PART OF EXTRACT
-- =============================================
CREATE OR REPLACE FUNCTION PUBLIC.EXTRACT_FROM_INTERVAL_UDF
(INTERVAL_DATA VARCHAR, INPUT_PART VARCHAR, REQUEST_PART VARCHAR)
RETURNS NUMBER
IMMUTABLE
AS
$$
    TO_NUMBER(DECODE(INPUT_PART,
           'DAY TO HOUR',     DECODE(REQUEST_PART,
                                     'DAY', SPLIT_PART(INTERVAL_DATA, ' ', 1),
                                     'HOUR',SPLIT_PART(INTERVAL_DATA, ' ', 2)
                                     ),
           'DAY TO MINUTE',   DECODE(REQUEST_PART,
                                     'DAY', SPLIT_PART(INTERVAL_DATA, ' ', 1),
                                     'HOUR', SPLIT_PART(SPLIT_PART(INTERVAL_DATA, ' ', 2), ':', 1),
                                     'MINUTE', SPLIT_PART(SPLIT_PART(INTERVAL_DATA, ' ', 2), ':', 2)
                                     ),
           'DAY TO SECOND',    DECODE(REQUEST_PART,
                                     'DAY', SPLIT_PART(INTERVAL_DATA, ' ', 1),
                                     'HOUR',SPLIT_PART(SPLIT_PART(INTERVAL_DATA, ' ', 2), ':', 1),
                                     'MINUTE', SPLIT_PART(SPLIT_PART(INTERVAL_DATA, ' ', 2), ':', 2),
                                     'SECOND', SPLIT_PART(SPLIT_PART(INTERVAL_DATA, ' ', 2), ':', 3)
                                     ),
           'HOUR TO MINUTE',   DECODE(REQUEST_PART,
                                     'HOUR', SPLIT_PART(INTERVAL_DATA, ':', 1),
                                     'MINUTE', SPLIT_PART(INTERVAL_DATA, ':', 2)
                                     ),
           'HOUR TO SECOND',   DECODE(REQUEST_PART,
                                     'HOUR', SPLIT_PART(INTERVAL_DATA, ':', 1),
                                     'MINUTE', SPLIT_PART(INTERVAL_DATA, ':', 2),
                                     'SECOND', SPLIT_PART(INTERVAL_DATA, ':', 3)
                                     ),
           'MINUTE TO SECOND', DECODE(REQUEST_PART,
                                     'MINUTE', SPLIT_PART(INTERVAL_DATA, ':', 1),
                                     'SECOND', SPLIT_PART(INTERVAL_DATA, ':', 2)
                                     )
            ))
$$;

-- =============================================
-- DISCLAIMER: THIS UDF IS DEPRECATED SINCE AN EQUIVALENT FOR THIS FUNCTION ALREADY EXISTS IN SNOWFLAKE
--  CHECK THE FOLLOWING LINK FOR FURTHER INFORMATION: https://docs.snowflake.com/en/sql-reference/functions/timediff.html
-- DESCRIPTION: UDF THAT GETS DIFFERENCE BETWEEN TWO TIMES 
-- PARAMETERS:
--  MINUEND: TIME - TIME SUBTRACTED FROM
--  SUBTRAHEND: TIME - TIME SUBTRACTED
--  INPUT_PART VARCHAR - RETURN DATA UNTIL PART
-- RETURN: VARCHAR WITH TIME
-- =============================================
CREATE OR REPLACE FUNCTION PUBLIC.TIME_DIFFERENCE_UDF
(MINUEND TIME, SUBTRAHEND TIME, INPUT_PART VARCHAR)
RETURNS VARCHAR
IMMUTABLE
AS
$$
DECODE(INPUT_PART,
        'HOUR',   CASE WHEN HOUR(MINUEND) <= HOUR(SUBTRAHEND) 
                    THEN TO_VARCHAR( HOUR(SUBTRAHEND) - HOUR(MINUEND)           , 'FM9900')
                    ELSE TO_VARCHAR( 24-ABS(HOUR(MINUEND) - HOUR(SUBTRAHEND))   , 'FM9900') END,
        'MINUTE', CASE WHEN HOUR(MINUEND) < HOUR(SUBTRAHEND) 
                    THEN TO_VARCHAR( CASE  WHEN  MINUTE(MINUEND)>MINUTE(SUBTRAHEND)  THEN  (HOUR(SUBTRAHEND) - HOUR(MINUEND)) - 1             ELSE  HOUR(SUBTRAHEND) - HOUR(MINUEND)            END, 'FM9900')
                    ELSE TO_VARCHAR( CASE  WHEN  MINUTE(MINUEND)>MINUTE(SUBTRAHEND)  THEN  (24-ABS(HOUR(MINUEND) - HOUR(SUBTRAHEND))) - 1     ELSE  24-ABS(HOUR(MINUEND) - HOUR(SUBTRAHEND))    END, 'FM9900')
                    END  || ':' ||
                  CASE WHEN MINUTE(MINUEND) <= MINUTE(SUBTRAHEND)
                    THEN TO_VARCHAR( MINUTE(SUBTRAHEND) - MINUTE(MINUEND)          , 'FM9900')
                    ELSE TO_VARCHAR( 60 - ABS(MINUTE(MINUEND) - MINUTE(SUBTRAHEND)), 'FM9900') END,
        'SECOND', CASE WHEN HOUR(MINUEND) <= HOUR(SUBTRAHEND)
                    THEN TO_VARCHAR( CASE WHEN MINUTE(MINUEND) > MINUTE(SUBTRAHEND)  THEN  (HOUR(SUBTRAHEND) - HOUR(MINUEND)) - 1             ELSE  HOUR(SUBTRAHEND) - HOUR(MINUEND)            END, 'FM9900')
                    ELSE TO_VARCHAR( CASE WHEN MINUTE(MINUEND) > MINUTE(SUBTRAHEND)  THEN  (24-ABS(HOUR(MINUEND) - HOUR(SUBTRAHEND))) - 1     ELSE  24-ABS(HOUR(MINUEND) - HOUR(SUBTRAHEND))    END, 'FM9900')
                    END || ':' ||
                  CASE WHEN MINUTE(MINUEND) <= MINUTE(SUBTRAHEND) 
                    THEN TO_VARCHAR( CASE WHEN SECOND(MINUEND) > SECOND(SUBTRAHEND)  THEN  (MINUTE(SUBTRAHEND) - MINUTE(MINUEND)) - 1         ELSE  MINUTE(SUBTRAHEND) - MINUTE(MINUEND)        END, 'FM9900')
                    ELSE TO_VARCHAR( CASE WHEN SECOND(MINUEND) > SECOND(SUBTRAHEND)  THEN  (60 - (MINUTE(MINUEND) - MINUTE(SUBTRAHEND))) - 1  ELSE  60 - (MINUTE(MINUEND) - MINUTE(SUBTRAHEND)) END, 'FM9900')
                    END || ':' ||
                  CASE WHEN SECOND(MINUEND) <= SECOND(SUBTRAHEND)
                    THEN TO_VARCHAR( SECOND(SUBTRAHEND) - SECOND(MINUEND),         'FM9900')
                    ELSE TO_VARCHAR( 60 - (SECOND(MINUEND) - SECOND(SUBTRAHEND)),  'FM9900')
                    END
      )
$$;
