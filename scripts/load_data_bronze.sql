
USE DataWarehouse;
GO
CREATE OR ALTER PROCEDURE bronze.load_data
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @start_time DATETIME, @end_time DATETIME;
    DECLARE @duration NVARCHAR(100);

    BEGIN TRY
        PRINT 'Loading data into bronze layer tables...';


        ----------- load data into bronze layer tables -----------   
        ----- /tmp is the folder where the csv files are stored in the docker container : filesystem isolation 

        PRINT 'Loading CRM tables...';



        ----------------- 1 cust_info table -----------------
        SET @start_time = GETDATE();
        TRUNCATE TABLE bronze.crm_cust_info;
        CREATE TABLE #crm_cust_info (
            cst_id NVARCHAR(50), cst_key NVARCHAR(50),
            cst_firstname NVARCHAR(50), cst_lastname NVARCHAR(50),
            cst_marital_status NVARCHAR(50), cst_gndr NVARCHAR(50),
            cst_create_date NVARCHAR(50)
        );
        BULK INSERT #crm_cust_info
        FROM '/tmp/cust_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0a',
            TABLOCK
        );
    
        INSERT INTO bronze.crm_cust_info
            (cst_id, cst_key, cst_firstname, cst_lastname, cst_marital_status, cst_gndr, cst_create_date)
        SELECT TRY_CONVERT(INT, cst_id), cst_key, cst_firstname, cst_lastname,
            cst_marital_status, cst_gndr, TRY_CONVERT(DATE, NULLIF(cst_create_date, ''), 23)
        FROM #crm_cust_info;
        DROP TABLE #crm_cust_info;
        SET @end_time = GETDATE();
        SET @duration = '-- Durée de chargement de crm_cust_info : ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(10)) + ' secondes';
        PRINT @duration;



        ------------------ 2 prd_info table -----------------
        SET @start_time = GETDATE();
        TRUNCATE TABLE bronze.crm_prd_info;
        CREATE TABLE #crm_prd_info (
            prd_id NVARCHAR(50), prd_key NVARCHAR(50), prd_nm NVARCHAR(50),
            prd_cost NVARCHAR(50), prd_line NVARCHAR(50),
            prd_start_dt NVARCHAR(50), prd_end_dt NVARCHAR(50)
        );
        BULK INSERT #crm_prd_info
        FROM '/tmp/prd_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0a',
            TABLOCK
        );
        INSERT INTO bronze.crm_prd_info
            (prd_id, prd_key, prd_nm, prd_cost, prd_line, prd_start_dt, prd_end_dt)
        SELECT TRY_CONVERT(INT, prd_id), prd_key, prd_nm, TRY_CONVERT(INT, NULLIF(prd_cost, '')),
            prd_line, TRY_CONVERT(DATE, NULLIF(prd_start_dt, ''), 23),
            TRY_CONVERT(DATE, NULLIF(prd_end_dt, ''), 23)
        FROM #crm_prd_info;
        DROP TABLE #crm_prd_info;
        SET @end_time = GETDATE();
        SET @duration = '-- Durée de chargement de crm_prd_info : ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(10)) + ' secondes';
        PRINT @duration;

        ------------------ 3. sales_details table -----------------
        SET @start_time = GETDATE();
        TRUNCATE TABLE bronze.crm_sales_details;
        CREATE TABLE #crm_sales_details (
            sls_ord_num NVARCHAR(50), sls_prd_key NVARCHAR(50),
            sls_cust_id NVARCHAR(50), sls_order_dt NVARCHAR(50),
            sls_ship_dt NVARCHAR(50), sls_due_dt NVARCHAR(50),
            sls_sales NVARCHAR(50), sls_quantity NVARCHAR(50), sls_price NVARCHAR(50)
        );
        BULK INSERT #crm_sales_details
        FROM '/tmp/sales_details.csv'
        WITH (      
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0a',
            TABLOCK
        ); 
        INSERT INTO bronze.crm_sales_details
            (sls_ord_num, sls_prd_key, sls_cust_id, sls_order_dt, sls_ship_dt,
             sls_due_dt, sls_sales, sls_quantity, sls_price)
        SELECT sls_ord_num, sls_prd_key, TRY_CONVERT(INT, NULLIF(sls_cust_id, '')),
            TRY_CONVERT(INT, NULLIF(sls_order_dt, '')),
            TRY_CONVERT(INT, NULLIF(sls_ship_dt, '')),
            TRY_CONVERT(INT, NULLIF(sls_due_dt, '')),
            TRY_CONVERT(INT, NULLIF(sls_sales, '')),
            TRY_CONVERT(INT, NULLIF(sls_quantity, '')),
            TRY_CONVERT(INT, NULLIF(sls_price, ''))
        FROM #crm_sales_details;
        DROP TABLE #crm_sales_details;
        SET @end_time = GETDATE();
        SET @duration = '-- Durée de chargement de crm_sales_details : ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(10)) + ' secondes';
        PRINT @duration;

        PRINT 'Loading ERP tables...';

        ------------------- 4 erp_cust_az12 table -----------------
        SET @start_time = GETDATE();
        TRUNCATE TABLE bronze.erp_cust_az12;
        CREATE TABLE #erp_cust_az12 (
            cid NVARCHAR(50), bdate NVARCHAR(50), gen NVARCHAR(50)
        );
        BULK INSERT #erp_cust_az12
        FROM '/tmp/CUST_AZ12.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0a',
            TABLOCK
        );
        INSERT INTO bronze.erp_cust_az12 (cid, bdate, gen)
        SELECT cid, TRY_CONVERT(DATE, NULLIF(bdate, ''), 23), gen
        FROM #erp_cust_az12;
        DROP TABLE #erp_cust_az12;
        SET @end_time = GETDATE();
        SET @duration = '-- Durée de chargement de erp_cust_az12 : ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(10)) + ' secondes';
        PRINT @duration;

        -------------------- 5 erp_loc_a101 table -----------------
        SET @start_time = GETDATE();
        TRUNCATE TABLE bronze.erp_loc_a101;
        CREATE TABLE #erp_loc_a101 (cid NVARCHAR(50), cntry NVARCHAR(50));
        BULK INSERT #erp_loc_a101
        FROM '/tmp/LOC_A101.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0a',
            TABLOCK
        );  
        INSERT INTO bronze.erp_loc_a101 (cid, cntry)
        SELECT cid, cntry FROM #erp_loc_a101;
        DROP TABLE #erp_loc_a101;
        SET @end_time = GETDATE();
        SET @duration = '-- Durée de chargement de erp_loc_a101 : ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(10)) + ' secondes';
        PRINT @duration;

        -------------------------- 6 erp_px_cat_g1v2 table -----------------
        SET @start_time = GETDATE();
        TRUNCATE TABLE bronze.erp_px_cat_g1v2;
        CREATE TABLE #erp_px_cat_g1v2 (
            id NVARCHAR(50), cat NVARCHAR(50), subcat NVARCHAR(50), maintenance NVARCHAR(50)
        );
        BULK INSERT #erp_px_cat_g1v2
        FROM '/tmp/PX_CAT_G1V2.csv'
        WITH (  
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0a',
            TABLOCK
        );
        INSERT INTO bronze.erp_px_cat_g1v2 (id, cat, subcat, maintenance)
        SELECT id, cat, subcat, maintenance FROM #erp_px_cat_g1v2;
        DROP TABLE #erp_px_cat_g1v2;
        SET @end_time = GETDATE();
        SET @duration = '-- Durée de chargement de erp_px_cat_g1v2 : ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(10)) + ' secondes';
        PRINT @duration;





        PRINT 'Chargement de la couche Bronze effectué avec succes ';

    END TRY
    BEGIN CATCH
        PRINT 'Erreur détectée pendant le chargement de la couche Bronze.';
        
        SELECT 
            ERROR_NUMBER() AS ErrorNumber,
            ERROR_SEVERITY() AS ErrorSeverity,
            ERROR_STATE() AS ErrorState,
            ERROR_LINE() AS ErrorLine,
            ERROR_MESSAGE() AS ErrorMessage;
            
        THROW;
    END CATCH

END;
GO


EXEC bronze.load_data;

