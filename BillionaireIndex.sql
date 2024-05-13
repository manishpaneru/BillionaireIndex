use project;
Select 
  * 
from 
  data;
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- so the names of the columns are easy to understand, so first we are changing it. 
-- first finalWorth to networth which is more commanly used term 
alter table 
  data change column finalWorth networth int;
-- now we need to change the column name from personName to name 
alter table 
  data change column personName name VARCHAR(255);
-- Now we change the name of the column category to industry so that we will understand easily
alter table 
  data change column category industry VARCHAR(255);
-- now we change the name of the country to countryofCitzenship to country 
alter table 
  data change column countryofCitizenship nation VARCHAR(255);
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- so the networth was in millions and before we change it we need to make sure that the column can handle it soo lets update the column first 
ALTER TABLE 
  data MODIFY COLUMN networth BIGINT;
-- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- now that column probelm is fixed , we need to change the networth from million to the  actual dollar values 
UPDATE 
  data 
SET 
  networth = networth * 1000000;
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- so let's see which country has the most billionaire 
select 
  * 
from 
  data;
select 
  country, 
  count(country) AS NumberOfBillionaire 
from 
  data 
GROUP BY 
  country 
ORDER BY 
  NumberOfBillionaire DESC;
-- so let's see how many country has more than 10 billionaire
SELECT 
  country, 
  COUNT(country) AS NumberOfBillionaire 
FROM 
  data 
GROUP BY 
  country 
HAVING 
  NumberOfBillionaire < 10 
ORDER BY 
  NumberOfBillionaire DESC;
-- Now lets see the number of bilionaire who are older than 75 
select 
  count(networth) AS Numberofbillionaire 
from 
  data 
where 
  age >= 75;
-- Alots of old billionaires who are old huh. 
-- Let's see how many millenials billionaires are there. 
Select 
  count(networth) AS Numberofbillionaires 
from 
  data 
where 
  birthYear >= 1981 
  AND birthYear <= 1996;
-- Damn 94 Millenial billionaires huh 
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- let's see how many billionaire are under the age 
Select 
  count(networth) AS Numberofbillionaires 
from 
  data 
where 
  birthYear >= 1997 
  AND birthYear <= 2012;
-- Damn only 2 GENZ billionaires 
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- let's see who is the richest GENZ 
select 
  name, 
  networth, 
  industry, 
  country, 
  age 
from 
  data 
where 
  birthYear >= 1997 
  AND birthYear <= 2012;
-- 18 and 21 only huh and both from same country and same industry and they share the same last name 
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- let's compare billionaire under 30 and billionaire over 90 
SELECT 
  COUNT(CASE WHEN age <= 30 THEN networth END) AS BillionaireUnder30, 
  COUNT(CASE WHEN age >= 90 THEN networth END) AS BillionaireOver90 
FROM 
  data;
-- alot of Old billionaires compared to the new ones. 
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Let's see which industry makes the most billionaires. 
select 
  distinct(industry), 
  count(industry) AS numberofbillionaires 
from 
  data 
Group by 
  (industry) 
ORDER BY 
  numberofbillionaires DESC;
-- Contrary to popular belief Finance and investments make more billionaire than technology. 
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Self made VS inherited wealth , let's see differnece kind of distribution in billionaire between self made compared to inherited wealth 
-- first let's change the column name to selfmade from selfMade
alter table 
  data change column selfMade selfmade VARCHAR(255);
-- now as the column name has been changed , let's move on 
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- let's first see the count of selfmade vs inherited billionaires 
select 
  DISTINCT(selfmade), 
  count(selfmade) 
from 
  data 
GROUP BY 
  selfmade;
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
select 
  industry, 
  COUNT(
    CASE WHEN selfmade = 'TRUE' THEN industry END
  ) AS SelfmadeBillonaires, 
  COUNT(
    CASE WHEN selfmade = 'FALSE' THEN industry END
  ) AS InheritedBillionaires 
FROM 
  data 
GROUP BY 
  industry;
-- soo that we know which idustry has more billionares 
-- So Finance and Technology has the most selfmade billionaires whereas Fashion and retail has the most inherited and old money billonaires
-- All the new age industry have more selfmade billionaires comapred to old age industry which has more inherited billionaires  
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
select 
  DISTINCT age, 
  COUNT(
    CASE WHEN selfmade = 'TRUE' THEN age END
  ) AS SelfMadeBillionaires, 
  COUNT(
    CASE WHEN selfmade = 'FALSE' THEN age END
  ) AS InheritedBillionaires 
from 
  data 
GROUP BY 
  age 
ORDER BY 
  age;
-- Soo we can see that bilionares of all ages have nearly equal distribution, we can see than in 2023 there are no selfmade billionaires under the age of 28. 
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- let's delve deep into economic factors peterning to the distribution of billionaires 
select 
  * 
from 
  data;
SELECT 
  COUNT(
    CASE WHEN CAST(
      REPLACE(
        REPLACE(gdp_country, '$', ''), 
        ',', 
        ''
      ) AS UNSIGNED
    ) < 1000000000000 THEN gdp_country END
  ) AS Underdeveloped, 
  COUNT(
    CASE WHEN CAST(
      REPLACE(
        REPLACE(gdp_country, '$', ''), 
        ',', 
        ''
      ) AS UNSIGNED
    ) > 1000000000000 THEN gdp_country END
  ) AS Developed 
FROM 
  data;
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
