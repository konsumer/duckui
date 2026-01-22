-- DuckDB UI Setup
INSTALL ui;
LOAD ui;
SET ui_local_port = 4213;

-- add any custom data setup here

INSTALL httpfs;
LOAD httpfs;

CREATE TABLE example_titanic AS
SELECT *
FROM read_parquet('https://www.timestored.com/data/sample/titanic.parquet')
