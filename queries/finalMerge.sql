/* Joining everything together */
SELECT
	STRFTIME("%d", a.timestamp) AS "DAY",
	
	ROUND(AVG(temperature), 1) AS "TEMP_AVG",
	
	MIN(temperature) AS "TEMP_MIN",
	STRFTIME("%H:%M", b.timestamp) AS "TEMP_MIN_TIME",
	
	MAX(temperature) AS "TEMP_MAX",
	STRFTIME("%H:%M", c.timestamp) AS "TEMP_MAX_TIME",
	
	MAX(temperature) - MIN(temperature) AS "TEMP_RANGE",
	
	ROUND(AVG(dewpoint), 1) AS "DEW_AVG",
	MIN(dewpoint) AS "DEW_MIN",
	MAX(dewpoint) AS "DEW_MAX",
	
	ROUND(AVG(heatIndex), 1) AS "HEATINDEX_AVG",
	MIN(heatIndex) AS "HEATINDEX_MIN",
	MAX(heatIndex) AS "HEATINDEX_MAX",
	
	
	ROUND(AVG(windchill), 1) AS "WINDCHILL_AVG",
	MIN(windchill) AS "WINDCHILL_MIN",
	MAX(windchill) AS "WINDCHILL_MAX",
	
	
	ROUND(AVG(relativeHumidity), 1) AS "HUMIDITY_AVG",
	MIN(relativeHumidity) AS "HUMIDITY_MIN",
	MAX(relativeHumidity) AS "HUMIDITY_MAX",
	
	ROUND(AVG(pressure), 1) AS "PRESSURE_AVG",
	MIN(pressure) AS "PRESSURE_MIN",
	MAX(pressure) AS "PRESSURE_MAX",
	
	ROUND(AVG(solarRadiation), 1) AS "SOLAR_RADIATION_AVG",
	MIN(solarRadiation) AS "SOLAR_RADIATION_MIN",
	MAX(solarRadiation) AS "SOLAR_RADIATION_MAX",

	/*raintRate),*/
	SUM(rain) AS "RAIN",
	
	ROUND(AVG(windSpeed), 1) AS "WIND_SPEED_AVG",
	ROUND(AVG(windSpeed) * 24, 1) AS "WIND_RUN",
	MAX(windSpeed) AS "WIND_SPEED_MAX",
	MAX(windGust) AS "WIND_GUST", /* ??? */
	ROUND(AVG(windDir), 2) AS "WIND_DIRECTION_AVG",
	
	
	/* Kaj je wind run ??? */
	COUNT(*) as "N_SAMPLES"
	

FROM customView as a
INNER JOIN minTempView AS b ON a.date = b.date
INNER JOIN maxTempView AS c ON a.date = c.date
GROUP BY "DAY"
ORDER BY "DAY" ASC;