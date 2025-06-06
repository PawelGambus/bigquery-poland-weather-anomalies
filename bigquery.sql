WITH PolishStations AS
(
  SELECT usaf AS station_id, name AS station_name 
  FROM `bigquery-public-data.noaa_gsod.stations`
  WHERE country = 'PL'
),
PolishStationDays AS
(
  SELECT ps.station_id, ps.station_name, cal_date
  FROM PolishStations ps
  CROSS JOIN UNNEST(GENERATE_DATE_ARRAY('2000-01-01', '2000-12-31')) AS cal_date
),
MeasurementsCleaned AS
(
  SELECT stn as station_id, CAST(CONCAT(year,'-',mo,'-',da) AS DATE) cal_date,
  --convert prcp values 99.99 to NULL. According to documentation: 99.99 means no report or insufficient data
  CASE
    WHEN
      prcp <> 99.99
    THEN
      prcp
    ELSE NULL
  END AS prcp,
  flag_prcp,
  --no missing data for temp 9999.9, hence no conversion to NULL markers
  temp
  FROM `bigquery-public-data.noaa_gsod.gsod2000`
),
MeasurementsCleanedDailyVal AS
(
  SELECT psd.station_id AS station_id, psd.station_name AS station_name,
    psd.cal_date AS cal_date, mc.prcp AS prcp, mc.flag_prcp AS flag_prcp, mc.temp AS temp
  FROM
  PolishStationDays  psd
  LEFT OUTER JOIN MeasurementsCleaned mc
  ON psd.station_id = mc.station_id AND psd.cal_date = mc.cal_date
), 
MeasurementsCalculations AS
(
  SELECT station_id, station_name, cal_date, flag_prcp, temp, prcp,
    LAG(flag_prcp) OVER (PARTITION BY station_id ORDER BY cal_date ASC) AS prev_day_flag_prcp,
    LAG(temp) OVER (PARTITION BY station_id ORDER BY cal_date ASC) AS prev_day_temp,
    --moving avg prcp will be calculated as an average of available data for the previous  7 days. 
    --If there are less than 7 previous measurements, the value will be calculated based on the available measurements.
    AVG(prcp) OVER (PARTITION BY station_id ORDER BY cal_date ASC ROWS BETWEEN 7 PRECEDING AND 1 PRECEDING) 
    AS avg_prev_7_days_prcp,
    --moving avg temp will be calculated as average of available data for the previous 4 days. 
    --If there are less than 4 previous measurements, the value will be calculated based on the available measurements.
    AVG(temp) OVER(PARTITION BY station_id ORDER BY cal_date ASC ROWS BETWEEN 4 PRECEDING AND 1 PRECEDING)
    AS avg_prev_4_days_temp
  FROM
  MeasurementsCleanedDailyVal
), 
WeatherBreakdowns AS
(
  SELECT station_id, station_name, cal_date FROM MeasurementsCalculations
  WHERE prev_day_flag_prcp = "I" AND 
    flag_prcp <> "I" AND 
    prcp > avg_prev_7_days_prcp AND 
    temp + 5.0 < avg_prev_4_days_temp 
)
SELECT station_id, station_name, count(cal_date) AS no_of_breakdowns 
FROM WeatherBreakdowns
GROUP BY station_id, station_name
ORDER BY no_of_breakdowns DESC LIMIT 1
;
