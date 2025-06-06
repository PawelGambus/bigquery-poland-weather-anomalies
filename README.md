# 🌦️ BigQuery – Weather Breakdown Analysis in Poland (2000)

This repository contains my solution to a recruitment task, which required writing an SQL query in BigQuery to detect sudden weather breakdowns in Poland in the year 2000.

---

## 📝 Task Description

Data source: public dataset `bigquery-public-data:noaa_gsod.gsod2000`.

### Goal:
Write an SQL query that detects sudden weather breakdowns in Polish meteorological stations during the year 2000. A weather breakdown is defined as a day that satisfies **all three** of the following conditions:

- The previous day had no recorded precipitation (`flag_prcp = 'I'`).
- Precipitation exceeds the moving average from the previous 7 days.
- Temperature is at least 5 degrees lower than the moving average from the previous 4 days.

The final result should indicate:
- which station experienced the most such breakdowns,
- and how many breakdowns occurred in total during the year.

---

## 🚀 My Approach and Execution

### ✅ Input Data Selection

- I used the `gsod2000` table, which contains daily measurements for weather stations.
- I also joined the `stations` table to filter only stations located in Poland (`country = 'PL'`).

### ✅ Handling Missing Data and Data Quality

- According to NOAA documentation, a `prcp` value of `99.99` means "no report or insufficient data" → I replaced it with `NULL`.
- The `temp` column did not require cleaning, as it had no placeholder values.

### ✅ Completing Dates and Data Gaps

- I generated a complete list of calendar days (`GENERATE_DATE_ARRAY`) for each Polish station to ensure continuity and detect gaps.
- Used a `LEFT JOIN` between stations and measurements to preserve dates with missing data.

### ✅ Computation and Logic

- Used `LAG()` to retrieve values from the previous day (`flag_prcp`, `temp`).
- Calculated moving averages for:
  - precipitation (`AVG(prcp)` over the 7 preceding days),
  - temperature (`AVG(temp)` over the 4 preceding days).
- All window functions are partitioned by `station_id` and ordered by `cal_date`.

### ✅ Final Detection and Output

- Filtered only days meeting all 3 breakdown conditions.
- Grouped results by station and sorted descending by the number of breakdown days to find the top one.

---

## 💡 Additional Notes

- The query ensures temporal continuity and includes days without measurements.
- Proper use of `LEFT JOIN` retains rows with missing daily values.
- The final outcome is based on strict, deterministic rule evaluation.

---

## 🧪 Technologies

- Google BigQuery
- Public dataset: `bigquery-public-data.noaa_gsod`

---

## 🧑‍💻 Author

Pawel Gambus  
[LinkedIn](https://www.linkedin.com/in/pawel-gambus)
