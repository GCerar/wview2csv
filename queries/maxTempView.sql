/* This view stores max daily temperature with timestamp */
CREATE TEMPORARY VIEW maxTempView AS SELECT
	"timestamp",
	"date",
	MAX(temperature)
FROM customView
GROUP BY "date"
ORDER BY timestamp ASC;