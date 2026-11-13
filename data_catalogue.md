# Gold Data Catalogue

The Gold layer exposes business-ready views in the `gold` schema. The views are
created by `scripts/build_gold_data.sql`; their inputs are the cleaned and
standardized Silver views/tables populated by
`scripts/cleaning_data_bronze _to_silver.sql`.

> **Object names:**
 The implemented names are `gold.dim_customers`,
> `gold.fact_sales`, and `gold.dim_products`. In particular, the SQL uses
> `customers` (not `custumers`) and `sales` (not `slaes`). These objects are
> views, despite often being referred to as Gold tables.

## Lineage overview

datasets/source_crm/cust_info.csv ──> bronze.crm_cust_info ──> silver.crm_cust_info ──┐
datasets/source_erp/CUST_AZ12.csv ──> bronze.erp_cust_az12 ──> silver.erp_cust_az12 ─┤
datasets/source_erp/LOC_A101.csv ──> bronze.erp_loc_a101 ──> silver.erp_loc_a101 ────┴─> gold.dim_customers ─┐
                                                                                                              ├─> gold.fact_sales
datasets/source_crm/sales_details.csv ─> bronze.crm_sales_details ─> silver.crm_sales_details ────────────────┘

datasets/source_crm/prd_info.csv ──────> bronze.crm_prd_info ──────> silver.crm_prd_info ──┐
datasets/source_erp/PX_CAT_G1V2.csv ───> bronze.erp_px_cat_g1v2 ───> silver.erp_px_cat_g1v2 ┴─> gold.dim_products ─┘


The Silver load deduplicates CRM customers by `cst_id`, standardizes names,
gender, marital status, product line, and country, derives product category
and product keys, creates product validity end dates, normalizes customer IDs,
and converts sales dates and numeric values. Gold views consume these Silver
outputs; they do not read the CSV files directly.

## `gold.dim_customers`

**Purpose:** Customer dimension enriched with ERP location, birth date, and
gender attributes.

**Grain:** One row per customer in `silver.crm_cust_info` (the Silver load keeps
one row per `cst_id`).

**Key:** `customer_key` is a query-generated `ROW_NUMBER()` ordered by
`cst_id`. `customer_id` is the CRM customer identifier; `customer_number` is
the CRM customer business key.

**Joins and lineage:**
----------------------------------------------------------------------------------------------------------------------------------------------------
|                 |                                               |                                                                                  |
| Gold column     | Source                                        | Description / derivation                                                         |
|                 |                                               |                                                                                  |
-----------------------------------------------------------------------------------------------------------------------------------------------------
|                |                                                |                                                                                  |
| `customer_key` | `silver.crm_cust_info.cst_id`                  | Generated row number ordered by CRM customer ID; surrogate key for this view.    |
|                |                                                |                                                                                  |
-----------------------------------------------------------------------------------------------------------------------------------------------------
|                 |                                               |                                                                                  |
| `customer_id`   | `silver.crm_cust_info.cst_id`                 | CRM customer ID; used to connect sales to the dimension. |
|                 |                                               |                                                                                  |
-----------------------------------------------------------------------------------------------------------------------------------------------------
|                 |                                               |                                                                                  |
|`customer_number`| `silver.crm_cust_info.cst_key`                | CRM customer business key; also used to match ERP customer and location records. |
|                 |                                               |                                                                                  |
-----------------------------------------------------------------------------------------------------------------------------------------------------
|                 |                                               |                                                                                  |
| `first_name`    | `silver.crm_cust_info.cst_firstname`          | Trimmed customer first name. |
|                 |                                               |                                                                                  |
-----------------------------------------------------------------------------------------------------------------------------------------------------
|                 |                                               |                                                                                  |
| `last_name`     | `silver.crm_cust_info.cst_lastname`           | Trimmed customer last name. |
|                 |                                               |                                                                                  |
-----------------------------------------------------------------------------------------------------------------------------------------------------
|                 |                                               |                                                                                  |
| `country`       | `silver.erp_loc_a101.cntry`                   | Customer country, matched on CRM `cst_key` = ERP `cid`. |
|                 |                                               |                                                                                  |
-----------------------------------------------------------------------------------------------------------------------------------------------------
|                 |                                               |                                                                                  |
| `marital_status`| `silver.crm_cust_info.cst_marital_status`     | Standardized CRM marital status. |
|                 |                                               |                                                                                  |
-----------------------------------------------------------------------------------------------------------------------------------------------------
|                 |                                               |                                                                                  |
| `gender`        | `silver.crm_cust_info.cst_gndr`; fallback     |      CRM gender with ERP gender as 
                    `silver.erp_cust_az12.gen`                    |       fallback; ERP matched on CRM `cst_key` = ERP `cid`.                        |
|                 |                                               |                                                                                  |                                                                
|                 |                                               |                                                                                  |
-----------------------------------------------------------------------------------------------------------------------------------------------------
|                 |                                               |                                                                                  |
| `birthdate`     | `silver.erp_cust_az12.bdate`                  | Customer birth date; ERP matched on CRM `cst_key` = ERP `cid`. |
|                 |                                               |                                                                                  |
-----------------------------------------------------------------------------------------------------------------------------------------------------
|                 |                                               |                                                                                  |
| `create_date`   | `silver.crm_cust_info.cst_create_date`        | CRM customer record creation date.                                               |
|                 |                                               |                                                                                  |
-----------------------------------------------------------------------------------------------------------------------------------------------------



Both ERP joins are left joins, so a customer remains in the view when an ERP
match is unavailable; unmatched ERP attributes are null.

## `gold.dim_products`

**Purpose:** Current product dimension enriched with product category,
subcategory, and maintenance attributes.

**Grain:** One row per current product version in `silver.crm_prd_info`.
Historical product versions are excluded by the `prd_end_dt IS NULL` filter.

**Key:** `product_key` is a query-generated `ROW_NUMBER()` ordered by product
start date and product key. `product_number` is the CRM product business key.

**Joins and lineage:**

-----------------------------------------------------------------------------------------------------------------------------------------------------
|                 |                                               |                                                                                  |
| Gold column     |         Source                                |                 Description / derivation                                         |
|                 |                                               |                                                                                  |
|----------------------------------------------------------------------------------------------------------------------------------------------------
|                 |                                               |                                                                                  |
| `product_key`   | `silver.crm_prd_info.prd_start_dt`, `prd_key` | Generated row number; surrogate key for this view.                               |
|                 |                                               |                                                                                  |
------------------------------------------------------------------------------------------------------------------------------------------------------
|                 |                                               |                                                                                  |
| `product_id`    | `silver.crm_prd_info.prd_id`                  |   CRM product ID.                                                                |
|                 |                                               |                                                                                  |
-----------------------------------------------------------------------------------------------------------------------------------------------------
|                 |                                               |                                                                                  |
| `product_number`| `silver.crm_prd_info.prd_key`                 | Product business key, derived in Silver from the CRM product key.                |
|                 |                                               |                                                                                  |
-----------------------------------------------------------------------------------------------------------------------------------------------------
|                 |                                               |                                                                                  |
| `product_name`  | `silver.crm_prd_info.prd_nm`                  | CRM product name.                                                                |
|                 |                                               |                                                                                  |
-----------------------------------------------------------------------------------------------------------------------------------------------------
|                 |                                               |                                                                                  |
| `category_id`   | `silver.crm_prd_info.cat_id`                  | Category key derived in Silver from the original CRM product key. |
|                 |                                               |                                                                                  |
------------------------------------------------------------------------------------------------------------------------------------------------------
|                 |                                               |                                                                                  |
| `category`      | `silver.erp_px_cat_g1v2.cat`                  | Category description; matched on CRM `cat_id` = ERP `id`.                        |
|                 |                                               |                                                                                  |
------------------------------------------------------------------------------------------------------------------------------------------------------
|                 |                                               |                                                                                  |
| `subcategory`   | `silver.erp_px_cat_g1v2.subcat`               | Product subcategory; same ERP category match.                                    |
|                 |                                               |                                                                                  |
-----------------------------------------------------------------------------------------------------------------------------------------------------
|                 |                                               |                                                                                  |
| `maintenance`   | `silver.erp_px_cat_g1v2.maintenance`          | ERP maintenance attribute; same ERP category match.                              |
|                 |                                               |                                                                                  |
------------------------------------------------------------------------------------------------------------------------------------------------------
|                 |                                               |                                                                                  |
| `cost`          | `silver.crm_prd_info.prd_cost`                | Product cost; null costs are set to zero in Silver.                              |
|                 |                                               |                                                                                  |
-----------------------------------------------------------------------------------------------------------------------------------------------------
|                 |                                               |                                                                                  |
| `product_line`  | `silver.crm_prd_info.prd_line`                | Standardized CRM product line.                                                   |
|                 |                                               |                                                                                  |
-----------------------------------------------------------------------------------------------------------------------------------------------------
|                 |                                               |                                                                                  |
| `start_date`    | `silver.crm_prd_info.prd_start_dt`            | Start date of the current product version.                                       |
|                 |                                               |                                                                                  |
------------------------------------------------------------------------------------------------------------------------------------------------------

The category join is a left join; products without a matching ERP category remain
in the view with null category attributes.

## `gold.fact_sales`

**Purpose:** Sales transaction fact enriched with the generated customer and
product dimension keys.

**Grain:** One row per source sales-detail record (a sales order line), at the
grain provided by `silver.crm_sales_details`.

**Dimension links:** `product_key` references `gold.dim_products.product_key`
through the product business key; `customer_key` references
`gold.dim_customers.customer_key` through the CRM customer ID. Both joins are
left joins, preserving sales rows even when a dimension lookup does not match.

-----------------------------------------------------------------------------------------------------------------------------------------------------
| Gold column     |      Source                            |           Description / derivation                                                     |
-----------------------------------------------------------------------------------------------------------------------------------------------------
|                 |                                        |                                                                                        |       
| `order_number`  | `silver.crm_sales_details.sls_ord_num` | Sales order number.                                                                    |
|                 |                                        |                                                                                        |
-----------------------------------------------------------------------------------------------------------------------------------------------------
|                 |                                        |                                                                                        |
| `product_key`   | `gold.dim_products.product_key`        | Product surrogate key, matched where sales `sls_prd_key` = dimension `product_number`. |
|                 |                                        |                                                                                        |
----------------------------------------------------------------------------------------------------------------------------------------------------
|                 |                                        |                                                                                        |
| `customer_key`  | `gold.dim_customers.customer_key`      | Customer surrogate key, matched where sales `sls_cust_id` = dimension `customer_id`.   |
|                 |                                        |                                                                                        |
-----------------------------------------------------------------------------------------------------------------------------------------------------
|                 |                                        |                                                                                        |
| `order_date`    | `silver.crm_sales_details.sls_order_dt`| Order date; invalid or zero dates are converted to null in Silver.                     |
|                 |                                        |                                                                                        |
-----------------------------------------------------------------------------------------------------------------------------------------------------
|                 |                                        |                                                                                        |
| `shipping_date` | `silver.crm_sales_details.sls_ship_dt` | Shipping date; invalid or zero dates are converted to null in Silver.                  |
|                 |                                        |                                                                                        |
-----------------------------------------------------------------------------------------------------------------------------------------------------
|                 |                                        |                                                                                        |
| `due_date`      | `silver.crm_sales_details.sls_due_dt`  | Due date; invalid or zero dates are converted to null in Silver.                       |
|                 |                                        |                                                                                        |
-----------------------------------------------------------------------------------------------------------------------------------------------------
|                 |                                        |                                                                                        |
| `sales_amount`  | `silver.crm_sales_details.sls_sales`   | Sales amount; Silver repairs missing or inconsistent values using quantity and price.  |
|                 |                                        |                                                                                        |
-----------------------------------------------------------------------------------------------------------------------------------------------------
|                 |                                        |                                                                                        |
| `quantity`      | `silver.crm_sales_details.sls_quantity`| Units sold.                                                                            |
|                 |                                        |                                                                                        |
-----------------------------------------------------------------------------------------------------------------------------------------------------
|                 |                                        |                                                                                        |
| `price`         | `silver.crm_sales_details.sls_price`   | Unit price; Silver repairs missing or inconsistent values using sales and quantity.    |
|                 |                                        |                                                                                        |
-----------------------------------------------------------------------------------------------------------------------------------------------------


## Usage and key considerations

- Join facts to dimensions using `customer_key` and `product_key`, rather than
  repeatedly joining on business identifiers.
- The surrogate keys are generated with `ROW_NUMBER()` in views, not persisted
  dimension keys. Their values may change if source rows or ordering change;
  do not treat them as durable identifiers across rebuilds.
- Since fact-to-dimension joins are left joins, a null dimension key indicates
  that the corresponding source business key did not match a row in the Gold
  dimension.