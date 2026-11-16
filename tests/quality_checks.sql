USE DataWarehouse;
GO




SELECT test_name, nb_problemes,
       CASE WHEN nb_problemes = 0 THEN 'OK' ELSE 'A VERIFIER' END AS statut
FROM (
    -- Silver
    SELECT 'Silver : clients sans identifiant (cst_id NULL)' AS test_name,
           COUNT(*) AS nb_problemes
    FROM silver.crm_cust_info
    WHERE cst_id IS NULL

    UNION ALL
    SELECT 'Silver : doublons de cst_id',
           COUNT(*)
    FROM (SELECT cst_id FROM silver.crm_cust_info GROUP BY cst_id HAVING COUNT(*) > 1) d

    UNION ALL
    SELECT 'Silver : lignes de vente perdues entre Bronze et Silver',
           ABS((SELECT COUNT(*) FROM bronze.crm_sales_details)
             - (SELECT COUNT(*) FROM silver.crm_sales_details))

    -- Gold
    UNION ALL
    SELECT 'Gold : doublons de customer_id dans dim_customers',
           COUNT(*)
    FROM (SELECT customer_id FROM gold.dim_customers GROUP BY customer_id HAVING COUNT(*) > 1) d

    UNION ALL
    SELECT 'Gold : doublons de product_number dans dim_products',
           COUNT(*)
    FROM (SELECT product_number FROM gold.dim_products GROUP BY product_number HAVING COUNT(*) > 1) d

    UNION ALL
    SELECT 'Gold : ventes sans client (customer_key NULL)',
           COUNT(*)
    FROM gold.fact_sales
    WHERE customer_key IS NULL

    UNION ALL
    SELECT 'Gold : ventes sans produit (product_key NULL)',
           COUNT(*)
    FROM gold.fact_sales
    WHERE product_key IS NULL
) t
ORDER BY test_name;
GO
