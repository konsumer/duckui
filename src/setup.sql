-- add any custom data setup here

-- this shows downloading & importing data (once)

CREATE TABLE example_titanic AS
SELECT *
FROM read_parquet('https://www.timestored.com/data/sample/titanic.parquet')
