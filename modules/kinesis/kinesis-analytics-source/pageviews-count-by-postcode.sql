CREATE OR REPLACE STREAM "DESTINATION_SQL_STREAM" (
    postcode        VARCHAR(4),
    event_datetime      TIMESTAMP,
    pageview_count  DOUBLE
);

CREATE OR REPLACE PUMP "STREAM_PUMP" AS 
  INSERT INTO "DESTINATION_SQL_STREAM" 
    SELECT STREAM 
        "postcode",
        FLOOR("event_datetime" TO MINUTE),
        COUNT("postcode") AS pageview_count
    FROM "SOURCE_SQL_STREAM_001"
    GROUP BY "postcode", FLOOR("event_datetime" TO MINUTE), STEP("SOURCE_SQL_STREAM_001".ROWTIME BY INTERVAL '1' MINUTE);

