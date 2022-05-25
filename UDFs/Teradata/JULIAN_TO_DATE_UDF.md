
# Definition and Usage
The JULIAN_TO_DATE_UDF() function takes a valid julian DATE string (YYYYDDD) and returns the DATE it represents, otherwise NULL.


## Syntax
`JULIAN_TO_DATE_UDF(julian_date)`

## Parameter Values
| Parameter	    | Description |
|---------------|-------------|
| julian_date	| Required. The string date in the Julian format (YYYYDDD).

## Snowflake Implementation

> Credit goes to James Demitriou

```sql
CREATE OR REPLACE FUNCTION PUBLIC.JULIAN_TO_DATE_UDF(JULIAN_DATE CHAR(7))
RETURNS DATE  
IMMUTABLE
AS
$$
  SELECT
    CASE 
        -- Assertion: Must be exactly 7 digits
        WHEN JULIAN_DATE NOT regexp '\\d{7}' THEN NULL
        -- Assertion: Don't accept 0 or negative days in DDD format
        WHEN RIGHT(JULIAN_DATE, 3)::INTEGER < 1 THEN NULL  
        -- Assertion: All years have 365 days 
        WHEN RIGHT(JULIAN_DATE, 3)::INTEGER <366 THEN ((LEFT(JULIAN_DATE, 4)||'-01-01')::DATE + RIGHT(JULIAN_DATE, 3)::INTEGER - 1)::DATE
        -- Assertion: If days part is 366, test for leap year (noting that the change of century is not a leap year, but the millenia is)
        WHEN RIGHT(JULIAN_DATE, 3)::INTEGER = 366 THEN
            CASE 
                WHEN SUBSTR(JULIAN_DATE, 2,3) = '000' THEN ((LEFT(JULIAN_DATE, 4)||'-01-01')::DATE + RIGHT(JULIAN_DATE, 3)::INTEGER - 1)::DATE -- valid millenia leap year
                WHEN SUBSTR(JULIAN_DATE, 3,2) = '00' THEN NULL -- Century years except millenia are not leap years
                WHEN MOD(LEFT(JULIAN_DATE,4)::INTEGER,4) = 0 THEN ((LEFT(JULIAN_DATE, 4)||'-01-01')::DATE + RIGHT(JULIAN_DATE, 3)::INTEGER - 1)::DATE -- valid leap year
            END
    ELSE -- days part is invalid
            NULL
    END
$$
;
```

 ## Examples 

```sql
select JULIAN_TO_DATE_UDF('2020000');   -- Returns null, invalid date
select JULIAN_TO_DATE_UDF('2020001');   -- Returns 2020-01-01
select JULIAN_TO_DATE_UDF('1900365');   -- Returns 1900-12-31
select JULIAN_TO_DATE_UDF('1903366');   -- Returns null, invalid date 
select JULIAN_TO_DATE_UDF('1900365');   -- Returns 1900-12-31 (century, no leap year)
select JULIAN_TO_DATE_UDF('1904060');   -- Returns 1904-02-29, valid leap year
select JULIAN_TO_DATE_UDF('1903060');   -- Returns 1903-03-01, non-leap year
select JULIAN_TO_DATE_UDF('2000366');   -- Returns 2000-12-31 (millenia, valid leap year)
select JULIAN_TO_DATE_UDF('2004366');   -- Returns 2004-12-31, valid leap year
```
