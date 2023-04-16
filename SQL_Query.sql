--After importing the data in the data acquisition stage,it enters the Scrub process

 
select * from Bakery_store..bakery

--Remove Duplicates: Identify and remove duplicate records in the data set.  «·»Ì«‰«  «·„ﬂ——Â
SELECT DISTINCT *

FROM bakery

-- Select the duplicate rows in the Bakery table using the ROW_NUMBER() function
SELECT *
FROM (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY Items, DateTime, [DayPart] ORDER BY [TransactionNo]) AS RN
    FROM bakery
) AS Dups
WHERE RN > 1;

--Delete duplicate rows

WITH CTE AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY [TransactionNo], 
	Items, DateTime, [DayPart] ORDER BY [TransactionNo]) AS RN
    FROM bakery
)
DELETE FROM CTE
WHERE RN > 1;

--Checking the number of rows after deleting duplicate values

select * from bakery

---------------------------------------------------------------------
--Handling missing values «· ⁄«„· „⁄ «·ﬁÌ„ «·„›ﬁÊœ…

SELECT [TransactionNo], Items, DateTime, [Daypart], DayType
FROM bakery
WHERE [TransactionNo] IS NULL
UNION
SELECT [TransactionNo], Items, DateTime, [Daypart], DayType
FROM bakery
WHERE Items IS NULL
UNION
SELECT [TransactionNo], Items, DateTime, [Daypart], DayType
FROM bakery
WHERE DateTime IS NULL
UNION
SELECT [TransactionNo], Items, DateTime, [Daypart], DayType
FROM bakery
WHERE [Daypart] IS NULL
UNION
SELECT [TransactionNo], Items, DateTime, [Daypart], DayType
FROM bakery
WHERE DayType IS NULL;

--------------------------------------------------------------
--Check the data types for each column «’·«Õ ‰Ê⁄ «·«⁄„œÂ

SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'bakery';

--Modify the data type of columns
ALTER TABLE bakery
ALTER COLUMN TransactionNo INT;

ALTER TABLE bakery
ALTER COLUMN Items VARCHAR(255);

ALTER TABLE bakery
ALTER COLUMN DateTime DATETIME;

ALTER TABLE bakery
ALTER COLUMN Daypart VARCHAR(10);

ALTER TABLE bakery
ALTER COLUMN DayType VARCHAR(10);

--We check the column type again
SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'bakery';

---------≈’·«Õ  ‰”Ìﬁ ⁄„Êœ «· «—ÌŒ Ê«·Êﬁ 
--Add two new columns to the "bakery" table to hold the "Date" and "Time" data
ALTER TABLE bakery
ADD Date DATE,
    Time TIME;

--Update the new "Date" and "Time" columns based on the values in the original "DateTime" column
UPDATE bakery
SET Date = CAST(DateTime AS DATE),
    Time = CAST(DateTime AS TIME);


--Delete the DateTime column

ALTER TABLE bakery
DROP COLUMN DateTime;

select * 
from bakery



-----------*****Explore*****---------------
--1 «·ŒÿÊÂ «·«Ê·Ï
--check the variable distributions of the "Items"

SELECT Items
FROM bakery

--to calculate the frequency of each item 

SELECT TOP 20 Items, COUNT(*) AS Frequency
FROM bakery
GROUP BY Items
order by Frequency desc

SELECT COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'bakery';
--Daypart

SELECT Daypart, COUNT(*) AS Frequency
FROM bakery
GROUP BY Daypart
order by Frequency desc

--2 «·ŒÿÊÂ «·À«‰ÌÂ


--- group the transactions by daypart

SELECT 
  daypart AS DayPart,
  COUNT(*) AS TransactionCount
FROM bakery
GROUP BY DayPart
order by TransactionCount desc

select * from bakery

--3 «·ŒÿÊÂ «·À«·ÀÂ 

--ÃœÊ· ÿÊ«—Ì

SELECT 
  daypart AS DayPart,
  COUNT(*) AS TransactionCount
FROM bakery
GROUP BY DayPart

---«· ﬂ—«—«  «·„ Êﬁ⁄Â

SELECT 
  SUM(TransactionCount) * (SELECT COUNT(*) FROM bakery) / (SELECT COUNT(*) FROM bakery) AS ExpectedCount,
  DayPart
FROM (
  SELECT 
    daypart AS DayPart,
    COUNT(*) AS TransactionCount
  FROM bakery
  GROUP BY DayPart
) t
GROUP BY DayPart
---- chi-square
SELECT 
  SUM((TransactionCount - ExpectedCount) * (TransactionCount - ExpectedCount) / ExpectedCount) AS ChiSquare,
  COUNT(*) - 1 AS DegreesOfFreedom
FROM (
  SELECT 
    daypart AS DayPart,
    COUNT(*) AS TransactionCount
  FROM bakery
  GROUP BY DayPart
) t
CROSS JOIN (
  SELECT 
    SUM(TransactionCount) * (SELECT COUNT(*) FROM bakery) / (SELECT COUNT(*) FROM bakery) AS ExpectedCount,
    DayPart
  FROM (
    SELECT 
      daypart AS DayPart,
      COUNT(*) AS TransactionCount
    FROM bakery
    GROUP BY DayPart
  ) s
  GROUP BY DayPart
) e

--------------
Select * from bakery
