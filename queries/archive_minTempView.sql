/* This view stores minimum daily temperature with timestamp */
CREATE TEMPORARY VIEW minTempView AS SELECT
	"timestamp",
	"date",
	MIN(temperature)
FROM customView
GROUP BY "date"
ORDER BY timestamp ASC;