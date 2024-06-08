-- Billionaire Statistics Analysis
-- A deep dive into the world of billionaires, their wealth, origins, and industries.
-- Get a glimpse of the data
SELECT 
  * 
FROM 
  data 
LIMIT 
  10;
-- What makes a billionaire? Uncover the diverse industries they hail from.
SELECT 
  DISTINCT category 
FROM 
  data;
-- The Titans of Wealth: Top 10 billionaires by net worth
SELECT 
  personName AS name, 
  finalWorth AS netWorth 
FROM 
  data 
ORDER BY 
  netWorth DESC 
LIMIT 
  10;
-- Billionaire Capitals: Which countries boast the most billionaires?
SELECT 
  country, 
  COUNT(personName) AS num_billionaires 
FROM 
  data 
GROUP BY 
  country 
ORDER BY 
  num_billionaires DESC;
-- Inside the American Dream: U.S. billionaires, their wealth origins, and industries.
SELECT 
  personName AS name, 
  source, 
  finalWorth AS networth, 
  industries AS industry 
FROM 
  data 
WHERE 
  country = 'United States';
-- Wisdom of Age: Billionaires aged 75 or older - experience or inheritance?
SELECT 
  personName AS name, 
  age, 
  finalWorth AS networth, 
  source 
FROM 
  data 
WHERE 
  age >= 75;
-- Industry Insights: Which industries mint the wealthiest billionaires?
SELECT 
  industries AS industry, 
  AVG(finalWorth) AS avg_networth 
FROM 
  data 
GROUP BY 
  industry 
ORDER BY 
  avg_networth DESC;
-- Nations of Wealth: Top 5 countries by total billionaire net worth
SELECT 
  country, 
  SUM(finalWorth) AS total_net_worth 
FROM 
  data 
GROUP BY 
  country 
ORDER BY 
  total_net_worth DESC 
LIMIT 
  5;
-- The Gender Gap: How many male and female billionaires are there in each category?
SELECT 
  category, 
  gender, 
  COUNT(*) AS num_billionaires 
FROM 
  data 
GROUP BY 
  category, 
  gender 
ORDER BY 
  category, 
  gender;
-- Self-Made vs. Silver Spoon: Average age difference between self-made and inherited billionaires.
SELECT 
  selfMade, 
  AVG(age) AS avg_age 
FROM 
  data 
GROUP BY 
  selfMade;
-- Billionaire Hubs: Top 3 cities teeming with the ultra-wealthy.
SELECT 
  city, 
  COUNT(*) AS num_billionaires 
FROM 
  data 
GROUP BY 
  city 
ORDER BY 
  num_billionaires DESC 
LIMIT 
  3;
-- Young and Restless: The youngest billionaire in each category.
SELECT 
  category, 
  personName AS name, 
  age 
FROM 
  data d1 
WHERE 
  age = (
    SELECT 
      MIN(age) 
    FROM 
      data d2 
    WHERE 
      d1.category = d2.category
  );
-- The Trailblazer: The oldest self-made billionaire still making waves.
SELECT 
  personName AS name, 
  age 
FROM 
  data 
WHERE 
  selfMade = True 
ORDER BY 
  age DESC 
LIMIT 
  1;
-- Birth Year Bonanza: Does birth year correlate with billionaire net worth?
SELECT 
  birthYear, 
  AVG(finalWorth) AS avg_net_worth 
FROM 
  data 
GROUP BY 
  birthYear 
ORDER BY 
  birthYear;
-- Wealth Origins: Top 5 sources that have produced the most billionaires.
SELECT 
  source, 
  COUNT(*) AS num_billionaires 
FROM 
  data 
GROUP BY 
  source 
ORDER BY 
  num_billionaires DESC 
LIMIT 
  5;
-- Captains of Industry: Self-made billionaires who still hold titles in their companies.
SELECT 
  personName AS name, 
  title 
FROM 
  data 
WHERE 
  title IS NOT NULL 
  AND selfMade = True;
-- Industry Giants: Average net worth per industry, but only for those with 10+ billionaires.
SELECT 
  industries AS industry, 
  AVG(finalWorth) AS avg_net_worth 
FROM 
  data 
GROUP BY 
  industry 
HAVING 
  COUNT(*) > 10 
ORDER BY 
  avg_net_worth DESC;
-- Self-Made Spirit: Percentage of self-made billionaires in each country.
SELECT 
  country, 
  (
    SUM(
      CASE WHEN selfMade = True THEN 1 ELSE 0 END
    ) / COUNT(*)
  ) * 100 AS percentage_self_made 
FROM 
  data 
GROUP BY 
  country 
ORDER BY 
  percentage_self_made DESC;
-- Wealth Inequality: How is wealth distributed among genders within each category?
WITH category_gender_worth AS (
  SELECT 
    category, 
    gender, 
    finalWorth, 
    ROW_NUMBER() OVER (
      PARTITION BY category, 
      gender 
      ORDER BY 
        finalWorth DESC
    ) AS rank_within_category_gender 
  FROM 
    data
) 
SELECT 
  category, 
  gender, 
  finalWorth, 
  NTILE(100) OVER (
    PARTITION BY category, 
    gender 
    ORDER BY 
      finalWorth
  ) AS percentile_within_category_gender 
FROM 
  category_gender_worth 
WHERE 
  rank_within_category_gender <= 10;
-- Age is Just a Number?: Exploring age trends among billionaires across birth years.
WITH age_stats AS (
  SELECT 
    birthYear, 
    AVG(age) AS avg_age, 
    PERCENTILE_CONT(0.5) WITHIN GROUP (
      ORDER BY 
        age
    ) OVER (PARTITION BY birthYear) AS median_age 
  FROM 
    data 
  GROUP BY 
    birthYear
) 
SELECT 
  birthYear, 
  avg_age, 
  median_age, 
  LAG(avg_age) OVER (
    ORDER BY 
      birthYear
  ) AS prev_avg_age, 
  LAG(median_age) OVER (
    ORDER BY 
      birthYear
  ) AS prev_median_age 
FROM 
  age_stats 
ORDER BY 
  birthYear;
-- Rags to Riches vs. Born with a Silver Spoon: Comparing the wealth and numbers of self-made vs. inherited billionaires.
WITH wealth_source AS (
  SELECT 
    selfMade, 
    SUM(finalWorth) AS total_wealth, 
    COUNT(*) AS num_billionaires 
  FROM 
    data 
  GROUP BY 
    selfMade
) 
SELECT 
  selfMade, 
  total_wealth, 
  num_billionaires, 
  total_wealth / (
    SELECT 
      SUM(total_wealth) 
    FROM 
      wealth_source
  ) AS wealth_proportion, 
  num_billionaires / (
    SELECT 
      SUM(num_billionaires) 
    FROM 
      wealth_source
  ) AS billionaire_proportion 
FROM 
  wealth_source;
-- City of Gold: Unveiling the cities where billionaires cluster and their combined wealth.
SELECT 
  country, 
  city, 
  COUNT() AS num_billionaires, 
  SUM(finalWorth) AS total_wealth, 
  RANK() OVER (
    ORDER BY 
      SUM(finalWorth) DESC
  ) AS wealth_rank, 
  RANK() OVER (
    ORDER BY 
      COUNT() DESC
  ) AS billionaire_rank 
FROM 
  data 
GROUP BY 
  country, 
  city 
HAVING 
  COUNT(*) >= 5 
ORDER BY 
  total_wealth DESC;
-- Industry Tycoons: The leading industry in each country, based on the number of billionaires it boasts.
WITH industry_country AS (
  SELECT 
    industries AS industry, 
    country, 
    COUNT() AS num_billionaires, 
    ROW_NUMBER() OVER (
      PARTITION BY country 
      ORDER BY 
        COUNT() DESC
    ) AS industry_rank 
  FROM 
    data 
  GROUP BY 
    industry, 
    country
) 
SELECT 
  country, 
  industry, 
  num_billionaires 
FROM 
  industry_country 
WHERE 
  industry_rank = 1;
-- The Billionaire Boom: Tracking the growth of total billionaire wealth over the years.
WITH yearly_wealth AS (
  SELECT 
    YEAR(date) AS year, 
    SUM(finalWorth) AS total_wealth 
  FROM 
    data 
  GROUP BY 
    YEAR(date)
) 
SELECT 
  year, 
  total_wealth, 
  (
    total_wealth - LAG(total_wealth) OVER (
      ORDER BY 
        year
    )
  ) / LAG(total_wealth) OVER (
    ORDER BY 
      year
  ) * 100 AS growth_percentage 
FROM 
  yearly_wealth 
ORDER BY 
  year;
-- The Wealth Divide: Analyzing the average and median net worth of billionaires by gender.
SELECT 
  gender, 
  AVG(finalWorth) AS avg_wealth, 
  PERCENTILE_CONT(0.5) WITHIN GROUP (
    ORDER BY 
      finalWorth
  ) OVER (PARTITION BY gender) AS median_wealth 
FROM 
  data 
GROUP BY 
  gender;
-- Outliers Among the Elite: Identifying billionaires who stand out in terms of wealth or age.
SELECT 
  personName AS name, 
  finalWorth, 
  age, 
  country, 
  industries AS industry, 
  wealth_decile, 
  age_decile 
FROM 
  (
    SELECT 
      name, 
      finalWorth, 
      age, 
      country, 
      industry, 
      NTILE(10) OVER (
        ORDER BY 
          finalWorth
      ) AS wealth_decile, 
      NTILE(10) OVER (
        ORDER BY 
          age
      ) AS age_decile 
    FROM 
      data
  ) subquery 
WHERE 
  wealth_decile = 10 
  OR age_decile IN (1, 10);
