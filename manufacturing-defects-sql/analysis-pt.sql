-- Número de defeitos por dia
SELECT "Day", SUM("Defects") AS total_defects, COUNT("Defects") AS sample_count
FROM defects
GROUP BY "Day"
ORDER BY "Day";

-- Média total de defeitos
SELECT SUM("Defects") / COUNT(DISTINCT "Day") AS average,
       COUNT(DISTINCT "Day") AS total_days
FROM defects;

-- Soma por faixa de horário
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

-- Soma por período
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

-- Top 10 horários com maior média de defeitos
SELECT "Sample", AVG("Defects") AS avg_defects
FROM defects
GROUP BY "Sample"
ORDER BY avg_defects DESC
LIMIT 10;

-- Pior e melhor dia
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

-- Ranking dos piores horários
SELECT RANK() OVER (ORDER BY average DESC) AS ranking, average, "Sample"
FROM (
    SELECT AVG("Defects") AS average, "Sample"
    FROM defects
    GROUP BY "Sample"
) AS sub
ORDER BY ranking;

-- Variação percentual entre manhã e tarde
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

-- Desvio da média geral
SELECT
    "Sample",
    AVG("Defects") AS avg_defects,
    AVG("Defects") - AVG(AVG("Defects")) OVER () AS deviation_from_overall_avg
FROM defects
GROUP BY "Sample"
ORDER BY deviation_from_overall_avg DESC;

-- Tendência ao longo dos dias (positivo = aumento de defeitos vs. dia anterior)
SELECT
    "Day",
    SUM("Defects") AS total_defects,
    SUM("Defects") - LAG(SUM("Defects")) OVER (ORDER BY "Day") AS diff_from_previous_day
FROM defects
GROUP BY "Day"
ORDER BY "Day";