CREATE STREAM message_stream (message VARCHAR)
WITH (KAFKA_TOPIC='input-topic', VALUE_FORMAT='JSON', PARTITIONS=3, REPLICAS=2);

CREATE STREAM words
WITH (KAFKA_TOPIC='words')
AS
SELECT EXPLODE(REGEXP_SPLIT_TO_ARRAY(LCASE(message), '\W+')) AS word
FROM message_stream;

CREATE TABLE word_counts
WITH (KAFKA_TOPIC='word-counts')
AS
SELECT word, COUNT(*) AS count
FROM words
GROUP BY word;

CREATE TABLE output_stream
WITH (KAFKA_TOPIC='output-topic')
AS
SELECT word, count
FROM word_counts
EMIT CHANGES;