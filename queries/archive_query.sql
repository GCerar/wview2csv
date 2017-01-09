ATTACH DATABASE "{hilow_db_path}" AS hilow;

CREATE TEMPORARY VIEW rainRateView AS SELECT
	/*DATETIME("dateTime", "unixepoch", "localtime") AS "timestamp",*/
	STRFTIME("%Y-%m-%d", DATETIME("dateTime", "unixepoch", "localtime")) AS "date",
	MAX(high) * 25.4 AS "rainRateMax" /* inch/h -> mm/h */
FROM hilow.rainRate
WHERE STRFTIME("%Y-%m", DATETIME("dateTime", "unixepoch", "localtime")) = "{year_month}" /* Limit month-year; Python do insert */
GROUP BY "date";


CREATE TEMPORARY VIEW windGustView AS SELECT
	/*DATETIME("dateTime", "unixepoch", "localtime") AS "timestamp",*/
	STRFTIME("%Y-%m-%d", DATETIME("dateTime", "unixepoch", "localtime")) AS "date",
	MAX(high) * 1.60934 AS "windGustMax" /* mph -> kmh */
FROM hilow.windGust
WHERE STRFTIME("%Y-%m", DATETIME("dateTime", "unixepoch", "localtime")) = "{year_month}" /* Limit month-year; Python do insert */
GROUP BY "date";
	
	
CREATE TEMPORARY VIEW windSpeedView AS SELECT
	/*DATETIME("dateTime", "unixepoch", "localtime") AS "timestamp",*/
	STRFTIME("%Y-%m-%d", DATETIME("dateTime", "unixepoch", "localtime")) AS "date",
	MAX(high) * 1.60934 AS "windSpeedMax" /* mph -> kmh */
FROM hilow.windSpeed
WHERE STRFTIME("%Y-%m", DATETIME("dateTime", "unixepoch", "localtime")) = "{year_month}" /* Limit month-year; Python do insert */
GROUP BY "date";


CREATE TEMPORARY VIEW maxValueView as SELECT
	rr.date AS "date",
	rr.rainRateMax AS "rainRateMax",
	wg.windGustMax AS "windGustMax",
	ws.windSpeedMax AS "windSpeedMax"
FROM rainRateView AS rr
INNER JOIN windGustView AS wg ON rr.date = wg.date
INNER JOIN windSpeedView AS ws ON rr.date = ws.date;




/* This view transforms empirical to metric units */
CREATE TEMPORARY VIEW customView AS SELECT
	DATETIME("dateTime", "unixepoch", "localtime") AS "timestamp",
	STRFTIME("%Y-%m-%d", DATETIME("dateTime", "unixepoch", "localtime")) AS "date",

	ROUND((outTemp - 32.0) * (5.0/9.0), 1) AS "temperature", /* F -> C */

	ROUND((dewpoint - 32.0) * (5.0/9.0), 1) AS "dewpoint", /* F -> C */

	ROUND((heatindex - 32.0) * (5.0/9.0), 1) AS "heatIndex", /* F -> C */
	ROUND((windchill - 32.0) * (5.0/9.0), 1) AS "windchill", /* F -> C */

	ROUND(outHumidity, 1) AS "relativeHumidity",
	ROUND(barometer * 3386.39 / 100, 1) AS "pressure", /* inHg -> hPa */
	ROUND(radiation, 2) as "solarRadiation",

	ROUND(rainRate * 25.4, 1) AS "rainRate", /* inch/h -> mm/h */
	ROUND(rain * 25.4, 1) AS "rain", /* inch -> mm */

	ROUND(windSpeed * 1.60934, 1) as "windSpeed", /* mph -> kmh */
	ROUND(windDir, 2) AS "windDir",
	ROUND(windGust * 1.60934, 1) AS "windGust", /* mph -> kmh */
	ROUND(windGustDir, 1) AS "windGustDir",

	ROUND(altimeter, 1) AS "altimeter", /* No idea about unit */
	ROUND(ET * 25.4, 1) AS ET,
	ROUND(UV, 1) AS UV

FROM main.archive
WHERE STRFTIME("%Y-%m", timestamp) = "{year_month}"; /* Limit month-year; Python do insert */


/* This view stores max daily temperature with timestamp */
CREATE TEMPORARY VIEW maxTempView AS SELECT
	"timestamp",
	"date",
	MAX(temperature)
FROM customView
GROUP BY "date";


/* This view stores minimum daily temperature with timestamp */
CREATE TEMPORARY VIEW minTempView AS SELECT
	"timestamp",
	"date",
	MIN(temperature)
FROM customView
GROUP BY "date";






/* Joining everything together */
CREATE TEMPORARY VIEW allData AS SELECT
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

	d.rainRateMax,
	SUM(rain) AS "RAIN",
	
	ROUND(AVG(windSpeed), 1) AS "WIND_SPEED_AVG",
	ROUND(AVG(windSpeed) * 24, 1) AS "WIND_RUN_AVG",
    d.windSpeedMax,
    d.windGustMax,
	ROUND(AVG(windDir), 2) AS "WIND_DIRECTION_AVG",
	
	COUNT(*) as "N_SAMPLES"
	

FROM customView as a
INNER JOIN minTempView AS b ON a.date = b.date
INNER JOIN maxTempView AS c ON a.date = c.date
INNER JOIN maxValueView AS d ON a.date = d.date
GROUP BY "DAY";
