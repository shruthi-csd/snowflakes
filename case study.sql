CREATE OR REPLACE DATABASE azure_demo_db;
USE DATABASE azure_demo_db;
USE SCHEMA PUBLIC;
CREATE OR REPLACE STAGE my_azure_stage
  URL='azure://salesdataacc.blob.core.windows.net/sales'
  CREDENTIALS = (
    AZURE_SAS_TOKEN='sv=2024-11-04&ss=bfqt&srt=sco&sp=rwdlacuptfx&se=2025-10-25T12:42:01Z&st=2025-10-24T04:27:01Z&spr=https&sig=OvtFYcgHaXaHA02auGMt9l33rJVFC5Pog6%2FZoNOQ6Fg%3D'
  );

-- Step 3: Verify files are visible
LIST @my_azure_stage;

-- Step 4: Create a file format (for CSV parsing)
CREATE OR REPLACE FILE FORMAT my_csv_format
  TYPE = 'CSV'
  FIELD_DELIMITER = ','
  SKIP_HEADER = 1
  FIELD_OPTIONALLY_ENCLOSED_BY = '"'
  NULL_IF = ('', 'NULL');

-- Step 5: Create table with correct schema (14 columns)
CREATE OR REPLACE TABLE SALES (
  ORDER_ID STRING,
  ORDER_DATE DATE,
  MONTH_OF_SALE STRING,
  CUSTOMER_ID STRING,
  CUSTOMER_NAME STRING,
  COUNTRY STRING,
  REGION STRING,
  CITY STRING,
  CATEGORY STRING,
  SUBCATEGORY STRING,
  QUANTITY NUMBER(10,2),
  DISCOUNT NUMBER(10,2),
  SALES NUMBER(10,2),
  PROFIT NUMBER(10,2)
);

-- Step 6: Preview CSV structure before loading (optional)
SELECT 
  $1 AS ORDER_ID,
  $2 AS ORDER_DATE,
  $3 AS MONTH_OF_SALE,
  $4 AS CUSTOMER_ID,
  $5 AS CUSTOMER_NAME,
  $6 AS COUNTRY,
  $7 AS REGION,
  $8 AS CITY,
  $9 AS CATEGORY,
  $10 AS SUBCATEGORY,
  $11 AS QUANTITY,
  $12 AS DISCOUNT,
  $13 AS SALES,
  $14 AS PROFIT
FROM @my_azure_stage/Retail_Sales__500_rows__Preview.csv
(FILE_FORMAT => 'my_csv_format')
LIMIT 10;

-- Step 7: Load CSV into the SALES table
COPY INTO SALES
FROM @my_azure_stage/Retail_Sales__500_rows__Preview.csv
FILE_FORMAT = (FORMAT_NAME = 'my_csv_format')
ON_ERROR = 'CONTINUE';

-- Step 8: Verify loaded data
SELECT * FROM SALES LIMIT 10;