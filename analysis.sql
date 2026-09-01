-- Number of defects per day
SELECT "Day", SUM("Defects") AS total_defects, COUNT("Defects") AS sample_count
FROM defects
GROUP BY "Day"
ORDER BY "Day";

-- Overall average defects
SELECT SUM("Defects") / COUNT(DISTINCT "Day") AS average,
       COUNT(DISTINCT "Day") AS total_days
FROM defects;

-- Sum by time range
SELECT time_range, SUM("Defects") AS defects_sum
FROM (
    SELECT "Defects", "Sample",
        CASE
            WHEN "Sample"::time <= '10:00' THEN '8-10'
            WHEN "Sample"::time <= '12:00' THEN '10-12'
            WHEN "Sample"::time <= '14:00' THEN '12-14'
            WHEN "Sample"::time <= '16:00' THEN '14-16'
        END AS time_range
    FROM defects
) AS sub
GROUP BY time_range
ORDER BY MIN("Sample"::time);

-- Sum by period (morning/afternoon)
SELECT day_period, SUM("Defects") AS defects_sum
FROM (
    SELECT "Defects", "Sample",
        CASE
            WHEN "Sample"::time < '12:00' THEN 'morning'
            ELSE 'afternoon'
        END AS day_period
    FROM defects
) AS sub
GROUP BY day_period
ORDER BY SUM("Defects") DESC;

-- Top 10 time slots with highest average defects
SELECT "Sample", AVG("Defects") AS avg_defects
FROM defects
GROUP BY "Sample"
ORDER BY avg_defects DESC
LIMIT 10;

-- Best and worst day
WITH daily_totals AS (
    SELECT "Day", SUM("Defects") AS total_defects
    FROM defects
    GROUP BY "Day"
)
SELECT "Day", total_defects,
    CASE
        WHEN total_defects = (SELECT MAX(total_defects) FROM daily_totals) THEN 'worst_day'
        WHEN total_defects = (SELECT MIN(total_defects) FROM daily_totals) THEN 'best_day'
    END AS label
FROM daily_totals
WHERE total_defects = (SELECT MAX(total_defects) FROM daily_totals)
   OR total_defects = (SELECT MIN(total_defects) FROM daily_totals);

-- Ranking of worst time slots
SELECT RANK() OVER (ORDER BY average DESC) AS ranking, average, "Sample"
FROM (
    SELECT AVG("Defects") AS average, "Sample"
    FROM defects
    GROUP BY "Sample"
) AS sub
ORDER BY ranking;

-- Percentage variation between morning and afternoon
SELECT
    SUM(CASE WHEN "Sample"::time < '12:00' THEN "Defects" END) AS morning_total,
    SUM(CASE WHEN "Sample"::time >= '12:00' THEN "Defects" END) AS afternoon_total,
    ROUND(
        (SUM(CASE WHEN "Sample"::time >= '12:00' THEN "Defects" END)
         - SUM(CASE WHEN "Sample"::time < '12:00' THEN "Defects" END))
        * 100.0
        / SUM(CASE WHEN "Sample"::time < '12:00' THEN "Defects" END),
    2) AS pct_afternoon_vs_morning
FROM defects;

-- Deviation from overall average
SELECT
    "Sample",
    AVG("Defects") AS avg_defects,
    AVG("Defects") - AVG(AVG("Defects")) OVER () AS deviation_from_overall_avg
FROM defects
GROUP BY "Sample"
ORDER BY deviation_from_overall_avg DESC;

-- Trend across days (positive = increase in defects vs. previous day)
SELECT
    "Day",
    SUM("Defects") AS total_defects,
    SUM("Defects") - LAG(SUM("Defects")) OVER (ORDER BY "Day") AS diff_from_previous_day
FROM defects
GROUP BY "Day"
ORDER BY "Day";
