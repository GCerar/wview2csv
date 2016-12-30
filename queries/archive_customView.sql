/* This view transforms empirical to metric units */
CREATE TEMPORARY VIEW customView AS SELECT
	DATETIME("dateTime", "unixepoch", "localtime") AS "timestamp",
	STRFTIME("%Y-%m-%d", DATETIME("dateTime", "unixepoch", "localtime")) AS "date",

	ROUND((outTemp - 32.0) * (5.0/9.0), 1) AS "temperature", /* F -> C */

	ROUND((dewpoint - 32.0) * (5.0/9.0), 1) AS "dewpoint", /* F -> C */

	ROUND((heatindex - 32.0) * (5.0/9.0), 1) AS "heatIndex", /* F -> C */
	ROUND((windchill - 32.0) * (5.0/9.0), 1) AS "windchill", /* F -> C */

	ROUND(outHumidity, 1) AS "relativeHumidity",
	ROUND(pressure * 3386.39 / 100, 1) AS "pressure", /* inHg -> hPa */
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

FROM archive
WHERE STRFTIME("%Y-%m", timestamp) = "{}" /* Limit month-year */
ORDER BY timestamp ASC;