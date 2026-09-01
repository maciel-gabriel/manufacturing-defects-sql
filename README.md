# Manufacturing Defects Analysis (SQL)

## Overview
Exploratory SQL analysis of a manufacturing defects dataset, identifying patterns by day, hour, and shift to support quality and production decisions.

## Dataset
Source: https://www.kaggle.com/datasets/gabrielsantello/manufacturing-defects-industry-dataset
Columns: Day, Sample (time), Defects.

## Tools
PostgreSQL, DBeaver

## Analysis
- Total defects per day
- Overall average defects
- Sum of defects by time range (8-10, 10-12, 12-14, 14-16)
- Sum of defects by period (morning vs. afternoon)
- Top 10 time slots with highest average defects
- Best and worst day
- Ranking of worst time slots (RANK)
- Percentage variation between morning and afternoon
- Deviation from overall average per time slot
- Day-over-day trend in total defects (LAG)

## Key Insights
- The afternoon shift recorded 17.37% more defects than the morning shift (1,784 vs. 1,520 total defects), with the 14:00-16:00 window being the most critical time range (848 defects).
- Day 10 was the worst-performing day (348 defects), 20 defects higher than the previous day — the largest single-day increase in the dataset.
- Days 2 and 6 tied as the best-performing days, both with 325 total defects.
- 15:00 was the single worst time slot (average of 11.8 defects, +1.48 above the overall average), while 11:00 was the best (average of 8.0 defects, -2.33 below average).
