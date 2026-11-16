USE DataWarehouse;
GO

CREATE OR ALTER PROCEDURE silver.load_silver 
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @start_time DATETIME, @end_time DATETIME;
    DECLARE @duration NVARCHAR(100);

    BEGIN TRY
        PRINT 'Loading data into silver layer tables...';

        --------------------------------- 1. CRM TABLES ----------------------------------

        ----------------- 1.1 crm_cust_info -----------------
        PRINT 'TRUNCATE TABLE silver.crm_cust_info';
        TRUNCATE TABLE silver.crm_cust_info;

        PRINT 'INSERT DATA INTO silver.crm_cust_info';
        SET @start_time = GETDATE();

        INSERT INTO silver.crm_cust_info (
            cst_id, cst_key, cst_firstname, cst_lastname, cst_gndr, cst_marital_status, cst_create_date, dwh_create_date
        )
        SELECT 
            cst_id,
            cst_key, 
            TRIM(cst_firstname) AS cst_firstname,
            TRIM(cst_lastname) AS cst_lastname,
            CASE 
                WHEN UPPER(TRIM(cst_gndr)) IN ('F', 'FEMALE') THEN 'Female'
                WHEN UPPER(TRIM(cst_gndr)) IN ('M', 'MALE') THEN 'Male'
                ELSE 'n/a'
            END AS cst_gndr,
            CASE 
                WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
                WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
                ELSE 'n/a'
            END AS cst_marital_status,
            cst_create_date,
            dwh_create_date
        FROM (
            SELECT *,
                   ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) as rn
            FROM bronze.crm_cust_info
        ) t
        WHERE rn = 1
          AND cst_id IS NOT NULL;   -- exclut les lignes clients sans identifiant

        SET @end_time = GETDATE();
        SET @duration = '-- Durée de chargement de crm_cust_info : ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(10)) + ' secondes';
        PRINT @duration;


        ----------------- 1.2 crm_prd_info -----------------
        PRINT 'TRUNCATE TABLE silver.crm_prd_info';
        TRUNCATE TABLE silver.crm_prd_info;

        PRINT 'INSERT DATA INTO silver.crm_prd_info';
        SET @start_time = GETDATE();

        INSERT INTO silver.crm_prd_info (
            prd_id, original_prd_key, cat_id, prd_key, prd_nm, prd_cost, prd_line, prd_start_dt, prd_end_dt, dwh_create_date
        )
        SELECT 
            prd_id,
            prd_key AS original_prd_key,
            REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
            SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,
            prd_nm,
            ISNULL(prd_cost, 0) AS prd_cost, 
            CASE 
                 WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
                 WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road' 
                 WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
                 WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other sales'
                 ELSE 'n/a'
            END AS prd_line,
            prd_start_dt,
            CAST(LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) AS DATE) AS prd_end_dt,
            dwh_create_date
        FROM bronze.crm_prd_info;

        SET @end_time = GETDATE();
        SET @duration = '-- Durée de chargement de crm_prd_info : ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(10)) + ' secondes';
        PRINT @duration;


        ----------------- 1.3 crm_sales_details -----------------
        PRINT 'TRUNCATE TABLE silver.crm_sales_details';
        TRUNCATE TABLE silver.crm_sales_details;

        PRINT 'INSERT DATA INTO silver.crm_sales_details';
        SET @start_time = GETDATE();

        INSERT INTO silver.crm_sales_details (
            sls_ord_num, sls_prd_key, sls_cust_id, sls_order_dt, sls_ship_dt, sls_due_dt, sls_quantity, sls_price, sls_sales, dwh_create_date
        )
        SELECT 
               sls_ord_num,
               sls_prd_key,
               sls_cust_id,
        CASE 
            WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL 
            ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
        END AS sls_order_dt,
        CASE 
             WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
             ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
        END AS sls_ship_dt,
        CASE 
              WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
              ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
        END AS sls_due_dt,
               sls_quantity,
        CASE 
            WHEN sls_price IS NULL OR TRY_CAST(sls_price AS DECIMAL(10,2)) <= 0 OR TRY_CAST(sls_price AS DECIMAL(10,2)) != TRY_CAST(ABS(sls_sales) AS DECIMAL(10,2)) / TRY_CAST(sls_quantity AS INT)  
            THEN TRY_CAST(ABS(sls_sales) AS DECIMAL(10,2)) / TRY_CAST(sls_quantity AS INT)
            ELSE sls_price
        END AS sls_price,
        CASE 
            WHEN sls_sales IS NULL OR TRY_CAST(sls_sales AS DECIMAL(10,2)) <= 0 
            OR TRY_CAST(sls_sales AS DECIMAL(10,2)) != TRY_CAST(sls_quantity AS INT) * TRY_CAST(ABS(sls_price) AS DECIMAL(10,2))
            THEN TRY_CAST(sls_quantity AS DECIMAL(10,2)) * TRY_CAST(ABS(sls_price) AS DECIMAL(10,2))
            ELSE sls_sales
        END AS sls_sales,
               dwh_create_date
        FROM bronze.crm_sales_details;

        SET @end_time = GETDATE();
        SET @duration = '-- Durée de chargement de crm_sales_details : ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(10)) + ' secondes';
        PRINT @duration;


        --------------------------------- 2. ERP TABLES ---------------------------------

        ----------------- 2.1 erp_cust_az12 -----------------
        PRINT 'TRUNCATE TABLE silver.erp_cust_az12';
        TRUNCATE TABLE silver.erp_cust_az12;

        PRINT 'INSERT DATA INTO silver.erp_cust_az12';
        SET @start_time = GETDATE();

        INSERT INTO silver.erp_cust_az12 (cid, bdate, gen, dwh_create_date)
        SELECT 
        CASE 
             WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
             ELSE cid 
        END AS cid,
        CASE 
            WHEN bdate > GETDATE() THEN NULL
            ELSE bdate 
        END AS bdate, 
        CASE 
            WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
            WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
            ELSE 'n/a'
        END AS gen, 
               dwh_create_date
        FROM bronze.erp_cust_az12;

        SET @end_time = GETDATE();
        SET @duration = '-- Durée de chargement de erp_cust_az12 : ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(10)) + ' secondes';
        PRINT @duration;


        ----------------- 2.2 erp_loc_a101 -----------------
        PRINT 'TRUNCATE TABLE silver.erp_loc_a101';
        TRUNCATE TABLE silver.erp_loc_a101;

        PRINT 'INSERT DATA INTO silver.erp_loc_a101';
        SET @start_time = GETDATE();

        INSERT INTO silver.erp_loc_a101 (cid, cntry, dwh_create_date)
        SELECT  
        CASE 
            WHEN cid LIKE '%-%' THEN REPLACE(cid, '-', '')
            ELSE cid 
        END AS cid, 
        CASE 
            WHEN TRIM(cntry) = 'DE' THEN 'Germany'
            WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
            WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
            ELSE TRIM(cntry)
        END AS cntry, 
        dwh_create_date 
        FROM bronze.erp_loc_a101;

        SET @end_time = GETDATE();
        SET @duration = '-- Durée de chargement de erp_loc_a101 : ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(10)) + ' secondes';
        PRINT @duration;


        ----------------- 2.3 erp_px_cat_g1v2 -----------------
        PRINT 'TRUNCATE TABLE silver.erp_px_cat_g1v2'; 
        TRUNCATE TABLE silver.erp_px_cat_g1v2;

        PRINT 'INSERT INTO silver.erp_px_cat_g1v2'; 
        SET @start_time = GETDATE();

        INSERT INTO silver.erp_px_cat_g1v2 (id, cat, subcat, maintenance, dwh_create_date)
        SELECT id, cat, subcat, maintenance, dwh_create_date
        FROM bronze.erp_px_cat_g1v2;

        SET @end_time = GETDATE();
        SET @duration = '-- Durée de chargement de erp_px_cat_g1v2 : ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(10)) + ' secondes';
        PRINT @duration;

        PRINT 'Chargement de la couche Silver effectué avec succès !';

    END TRY
    BEGIN CATCH
        PRINT 'Error occurred: ' + ERROR_MESSAGE();
        THROW;
    END CATCH
END;
GO

EXEC silver.load_silver;