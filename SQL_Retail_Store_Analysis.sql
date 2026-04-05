use orders;

-- 1. WRITE A QUERY TO DISPLAY CUSTOMER FULL NAME WITH THEIR TITLE(MR/MS), BOTH FIRST NAME AND LAST NAME ARE IN UPPER 
-- CASE WITH CUSTOMER EMAIL ID, CUSTOMER CREATION DATE AND DISPLAY CUSTOMER'S CATEGORY AFTER APPLYING BELOW CATEGORIZATION RULES:
	-- i.IF CUSTOMER CREATION DATE YEAR <2005 THEN CATEGORY A
    -- ii.IF CUSTOMER CREATION DATE YEAR >=2005 AND <2011 THEN CATEGORY B
    -- iii.IF CUSTOMER CREATION DATE YEAR>= 2011 THEN CATEGORY C
	-- HINT: USE CASE STATEMENT, NO PERMANENT CHANGE IN TABLE REQUIRED. [NOTE: TABLES TO BE USED -ONLINE_CUSTOMER TABLE]

SELECT 
    CONCAT(CASE
                WHEN customer_gender = 'M' THEN 'MR '
                WHEN customer_gender = 'F' THEN 'MS '
            END,
            UPPER(customer_fname),
            ' ',
            UPPER(customer_lname)) AS customer_fullname,
    customer_email,
    customer_creation_date,
    CASE
        WHEN YEAR(customer_creation_date) < 2005 THEN 'CATEGORY A'
        WHEN
            YEAR(customer_creation_date) >= 2005
                AND YEAR(customer_creation_date) < 2011
        THEN
            'CATEGORY B'
        WHEN YEAR(customer_creation_date) >= 2011 THEN 'CATEGORY C'
    END AS customer_category
FROM
    online_customer;
    
-- 2. WRITE A QUERY TO DISPLAY THE FOLLOWING INFORMATION FOR THE PRODUCTS, WHICH HAVE NOT BEEN SOLD:  PRODUCT_ID, PRODUCT_DESC, 
-- PRODUCT_QUANTITY_AVAIL, PRODUCT_PRICE,INVENTORY VALUES(PRODUCT_QUANTITY_AVAIL*PRODUCT_PRICE), NEW_PRICE AFTER APPLYING DISCOUNT 
-- AS PER BELOW CRITERIA. SORT THE OUTPUT WITH RESPECT TO DECREASING VALUE OF INVENTORY_VALUE.
	-- i.IF PRODUCT PRICE > 20,000 THEN APPLY 20% DISCOUNT
    -- ii.IF PRODUCT PRICE > 10,000 THEN APPLY 15% DISCOUNT
    -- iii.IF PRODUCT PRICE =< 10,000 THEN APPLY 10% DISCOUNT
    
    -- HINT: USE CASE STATEMENT, NO PERMANENT CHANGE IN TABLE REQUIRED. [NOTE: TABLES TO BE USED -PRODUCT, ORDER_ITEMS TABLE]
SELECT 
    p.product_id,
    p.product_desc,
    p.product_quantity_avail,
    p.product_price,
    p.product_quantity_avail * product_price AS inventory_value,
    CASE
        WHEN p.product_price > 20000 THEN ROUND(p.product_price * 0.80, 2)
        WHEN p.product_price > 10000 THEN ROUND(p.product_price * 0.85, 2)
        WHEN p.product_price <= 10000 THEN ROUND(p.product_price * 0.90, 2)
    END AS new_price
FROM
    product p
        LEFT JOIN
    order_items o ON p.product_id = o.product_id
WHERE
    o.order_id IS NULL
ORDER BY inventory_value DESC;

-- 3. WRITE A QUERY TO DISPLAY PRODUCT_CLASS_CODE, PRODUCT_CLASS_DESCRIPTION, COUNT OF PRODUCT TYPE IN EACH PRODUCT CLASS, 
-- INVENTORY VALUE (P.PRODUCT_QUANTITY_AVAIL*P.PRODUCT_PRICE). INFORMATION SHOULD BE DISPLAYED FOR ONLY THOSE PRODUCT_CLASS_CODE 
-- WHICH HAVE MORE THAN 1,00,000 INVENTORY VALUE. SORT THE OUTPUT WITH RESPECT TO DECREASING VALUE OF INVENTORY_VALUE.
	-- [NOTE: TABLES TO BE USED -PRODUCT, PRODUCT_CLASS]
SELECT 
    p.product_class_code,
    pc.product_class_desc,
    COUNT(p.product_desc) AS product_type,
    SUM(p.product_quantity_avail * p.product_price) AS inventory_value
FROM
    product p
        INNER JOIN
    product_class pc ON p.product_class_code = pc.product_class_code
GROUP BY p.product_class_code , pc.product_class_desc
HAVING inventory_value > 100000
ORDER BY inventory_value DESC;

-- 4. WRITE A QUERY TO DISPLAY CUSTOMER_ID, FULL NAME, CUSTOMER_EMAIL, CUSTOMER_PHONE AND COUNTRY OF CUSTOMERS WHO HAVE CANCELLED 
-- ALL THE ORDERS PLACED BY THEM(USE SUB-QUERY)
	-- [NOTE: TABLES TO BE USED - ONLINE_CUSTOMER, ADDRESSS, ORDER_HEADER]
SELECT 
    c.customer_id,
    CONCAT(c.customer_fname, ' ', c.customer_lname) AS customers_full_name,
    c.customer_email,
    c.customer_phone,
    (SELECT 
            country
        FROM
            address
        WHERE
            address_id = c.address_id) AS country
FROM
    online_customer c
WHERE
    c.customer_id IN (SELECT 
            o.customer_id
        FROM
            order_header o
        WHERE
            o.order_status = 'Cancelled'
        GROUP BY o.customer_id
        HAVING COUNT(*) = (SELECT 
                COUNT(*)
            FROM
                order_header
            WHERE
                customer_id = o.customer_id));
                
-- 5. WRITE A QUERY TO DISPLAY SHIPPER NAME, CITY TO WHICH IT IS CATERING, NUMBER OF CUSTOMER CATERED BY THE SHIPPER IN THE CITY AND 
-- NUMBER OF CONSIGNMENTS DELIVERED TO THAT CITY FOR SHIPPER DHL(9 ROWS)
	-- [NOTE: TABLES TO BE USED -SHIPPER, ONLINE_CUSTOMER, ADDRESSS, ORDER_HEADER]

SELECT 
    s.shipper_name,
    (SELECT 
            city
        FROM
            address a
        WHERE
            a.address_id = c.address_id) AS catering_city,
    COUNT(DISTINCT o.customer_id) AS no_of_customers,
    COUNT(o.order_id) AS no_of_consignments
FROM
    shipper s
        JOIN
    order_header o ON s.shipper_id = o.shipper_id
        JOIN
    online_customer c ON c.customer_id = o.customer_id
WHERE
    s.shipper_name = 'DHL'
GROUP BY s.shipper_name , catering_city;


;

-- 6. WRITE A QUERY TO DISPLAY CUSTOMER ID, CUSTOMER FULL NAME, TOTAL QUANTITY AND TOTAL VALUE (QUANTITY*PRICE) SHIPPED WHERE MODE 
-- OF PAYMENT IS CASH AND CUSTOMER LAST NAME STARTS WITH 'G'
	-- [NOTE: TABLES TO BE USED -ONLINE_CUSTOMER, ORDER_ITEMS, PRODUCT, ORDER_HEADER]
    
SELECT 
    OC.customer_id AS Customer_ID,
    CONCAT(Customer_fname, ' ', Customer_lname) AS Customer_Full_Name,
    SUM(Product_quantity) AS Total_Quantity,
    SUM(Product_quantity * product_price) AS Total_Value
FROM 
    ONLINE_CUSTOMER OC
JOIN 
    ORDER_HEADER OH ON OC.customer_id = OH.customer_id
JOIN 
    ORDER_ITEMS OI ON OH.order_id = OI.order_id
JOIN 
    PRODUCT P ON OI.product_id = P.product_id
WHERE 
    OH.payment_mode = 'CASH'
    AND Customer_lname LIKE 'G%'
GROUP BY 
    OC.customer_id, Customer_fname, Customer_lname;


    
-- 7. WRITE A QUERY TO DISPLAY ORDER_ID AND VOLUME OF BIGGEST ORDER (IN TERMS OF VOLUME) THAT CAN FIT IN CARTON ID 10  
	-- [NOTE: TABLES TO BE USED -CARTON, ORDER_ITEMS, PRODUCT]
    
SELECT oi.order_id, SUM(p.len * p.width * p.height * oi.product_quantity) AS total_volume
FROM order_items oi
JOIN product p ON oi.product_id = p.product_id
WHERE oi.order_id IN (
    SELECT oi2.order_id
    FROM order_items oi2
    JOIN product p2 ON oi2.product_id = p2.product_id
    WHERE oi2.product_quantity <= (
        SELECT (c.len * c.width * c.height)
        FROM carton c
        WHERE c.carton_id = 10
    )
)
GROUP BY oi.order_id
ORDER BY total_volume DESC
LIMIT 1;


-- 8. WRITE A QUERY TO DISPLAY PRODUCT_ID, PRODUCT_DESC, PRODUCT_QUANTITY_AVAIL, QUANTITY SOLD, AND SHOW INVENTORY STATUS OF 
-- PRODUCTS AS BELOW AS PER BELOW CONDITION:
	-- A.FOR ELECTRONICS AND COMPUTER CATEGORIES, 
		-- i.IF SALES TILL DATE IS ZERO THEN SHOW 'NO SALES IN PAST, GIVE DISCOUNT TO REDUCE INVENTORY',
        -- ii.IF INVENTORY QUANTITY IS LESS THAN 10% OF QUANTITY SOLD, SHOW 'LOW INVENTORY, NEED TO ADD INVENTORY', 
        -- iii.IF INVENTORY QUANTITY IS LESS THAN 50% OF QUANTITY SOLD, SHOW 'MEDIUM INVENTORY, NEED TO ADD SOME INVENTORY', 
        -- iv.IF INVENTORY QUANTITY IS MORE OR EQUAL TO 50% OF QUANTITY SOLD, SHOW 'SUFFICIENT INVENTORY'
	-- B.FOR MOBILES AND WATCHES CATEGORIES, 
		-- i.IF SALES TILL DATE IS ZERO THEN SHOW 'NO SALES IN PAST, GIVE DISCOUNT TO REDUCE INVENTORY', 
        -- ii.IF INVENTORY QUANTITY IS LESS THAN 20% OF QUANTITY SOLD, SHOW 'LOW INVENTORY, NEED TO ADD INVENTORY',  
        -- iii.IF INVENTORY QUANTITY IS LESS THAN 60% OF QUANTITY SOLD, SHOW 'MEDIUM INVENTORY, NEED TO ADD SOME INVENTORY', 
        -- iv.IF INVENTORY QUANTITY IS MORE OR EQUAL TO 60% OF QUANTITY SOLD, SHOW 'SUFFICIENT INVENTORY'
	-- C.REST OF THE CATEGORIES, 
		-- i.IF SALES TILL DATE IS ZERO THEN SHOW 'NO SALES IN PAST, GIVE DISCOUNT TO REDUCE INVENTORY', 
        -- ii.IF INVENTORY QUANTITY IS LESS THAN 30% OF QUANTITY SOLD, SHOW 'LOW INVENTORY, NEED TO ADD INVENTORY',  
        -- iii.IF INVENTORY QUANTITY IS LESS THAN 70% OF QUANTITY SOLD, SHOW 'MEDIUM INVENTORY, NEED TO ADD SOME INVENTORY', 
        -- iv. IF INVENTORY QUANTITY IS MORE OR EQUAL TO 70% OF QUANTITY SOLD, SHOW 'SUFFICIENT INVENTORY'
        
			-- [NOTE: TABLES TO BE USED -PRODUCT, PRODUCT_CLASS, ORDER_ITEMS] (USE SUB-QUERY)
	
SELECT 
    p.product_id,
    p.product_desc,
    p.product_quantity_avail,
    SUM(oi.product_quantity) AS quantity_sold,
    CASE 
        WHEN pc.PRODUCT_CLASS_DESC IN ('Electronics', 'Computer') THEN
            CASE 
                WHEN COALESCE(SUM(oi.product_quantity), 0) = 0 THEN 'NO SALES IN PAST, GIVE DISCOUNT TO REDUCE INVENTORY'
                WHEN p.product_quantity_avail < 0.1 * SUM(oi.product_quantity) THEN 'LOW INVENTORY, NEED TO ADD INVENTORY'
                WHEN p.product_quantity_avail < 0.5 * SUM(oi.product_quantity) THEN 'MEDIUM INVENTORY, NEED TO ADD SOME INVENTORY'
                ELSE 'SUFFICIENT INVENTORY'
            END
        WHEN pc.PRODUCT_CLASS_DESC IN ('Mobiles', 'Watches') THEN
            CASE 
                WHEN COALESCE(SUM(oi.product_quantity), 0) = 0 THEN 'NO SALES IN PAST, GIVE DISCOUNT TO REDUCE INVENTORY'
                WHEN p.product_quantity_avail < 0.2 * SUM(oi.product_quantity) THEN 'LOW INVENTORY, NEED TO ADD INVENTORY'
                WHEN p.product_quantity_avail < 0.6 * SUM(oi.product_quantity) THEN 'MEDIUM INVENTORY, NEED TO ADD SOME INVENTORY'
                ELSE 'SUFFICIENT INVENTORY'
            END
        ELSE
            CASE 
                WHEN COALESCE(SUM(oi.product_quantity), 0) = 0 THEN 'NO SALES IN PAST, GIVE DISCOUNT TO REDUCE INVENTORY'
                WHEN p.product_quantity_avail < 0.3 * SUM(oi.product_quantity) THEN 'LOW INVENTORY, NEED TO ADD INVENTORY'
                WHEN p.product_quantity_avail < 0.7 * SUM(oi.product_quantity) THEN 'MEDIUM INVENTORY, NEED TO ADD SOME INVENTORY'
                ELSE 'SUFFICIENT INVENTORY'
            END
    END AS inventory_status
FROM 
    product p
JOIN 
    product_class pc ON p.product_class_code = pc.product_class_code
LEFT JOIN 
    order_items oi ON p.product_id = oi.product_id
GROUP BY 
    p.product_id, p.product_desc, p.product_quantity_avail, pc.PRODUCT_CLASS_DESC;

    
-- 9. WRITE A QUERY TO DISPLAY PRODUCT_ID, PRODUCT_DESC AND TOTAL QUANTITY OF PRODUCTS WHICH ARE SOLD TOGETHER WITH PRODUCT ID 201 
-- AND ARE NOT SHIPPED TO CITY BANGALORE AND NEW DELHI. DISPLAY THE OUTPUT IN DESCENDING ORDER WITH RESPECT TO TOT_QTY.(USE SUB-QUERY)
	-- [NOTE: TABLES TO BE USED -ORDER_ITEMS,PRODUCT,ORDER_HEADER, ONLINE_CUSTOMER, ADDRESS]
  SELECT 
    oi.PRODUCT_ID,
    p.PRODUCT_DESC,
    SUM(Product_QUANTITY) AS TOT_QTY
FROM 
    ORDER_ITEMS oi
JOIN 
    PRODUCT p ON oi.PRODUCT_ID = p.PRODUCT_ID
JOIN 
    ORDER_HEADER oh ON oi.ORDER_ID = oh.ORDER_ID
JOIN 
    ONLINE_CUSTOMER oc ON oh.CUSTOMER_ID = oc.CUSTOMER_ID
JOIN 
    ADDRESS a ON oc.ADDRESS_ID = a.ADDRESS_ID
WHERE 
    oi.ORDER_ID IN (
        SELECT 
            oi1.ORDER_ID
        FROM 
            ORDER_ITEMS oi1
        WHERE 
            oi1.PRODUCT_ID = 201
    )
    AND a.CITY NOT IN ('Bangalore', 'New Delhi')
GROUP BY 
    oi.PRODUCT_ID,
    p.PRODUCT_DESC
ORDER BY 
    TOT_QTY DESC;
  
  
  
-- 10. WRITE A QUERY TO DISPLAY THE ORDER_ID,CUSTOMER_ID AND CUSTOMER FULLNAME AND TOTAL QUANTITY OF PRODUCTS SHIPPED FOR ORDER IDS 
-- WHICH ARE EVENAND SHIPPED TO ADDRESS WHERE PINCODE IS NOT STARTING WITH "5" 
	-- [NOTE: TABLES TO BE USED - ONLINE_CUSTOMER,ORDER_HEADER, ORDER_ITEMS, ADDRESS]
  SELECT O.ORDER_ID, 
O.CUSTOMER_ID, 
CONCAT(C.CUSTOMER_FNAME, ' ', C.CUSTOMER_LNAME) AS CUSTOMER_FULL_NAME,
(SELECT 
            SUM(PRODUCT_QUANTITY)
        FROM 
            ORDER_ITEMS OI
        WHERE 
            OI.ORDER_ID = O.ORDER_ID) AS TOTAL_QUANTITY_OF_PRODUCTS_SHIPPED
FROM ORDER_HEADER O
JOIN ONLINE_CUSTOMER C ON O.CUSTOMER_ID = C.CUSTOMER_ID
WHERE O.ORDER_ID % 2 = 0 -- Check if order_id is even
AND SUBSTRING((SELECT 
            SHIPPER_ADDRESS
        FROM 
            SHIPPER
        WHERE 
            SHIPPER_ID = O.SHIPPER_ID), 1, 1) <> '5' -- Check if pincode doesn't start with "5"
GROUP BY O.ORDER_ID, O.CUSTOMER_ID; 



