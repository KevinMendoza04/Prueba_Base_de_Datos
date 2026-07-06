-- =============================================================
-- RiwiSupply S.A.S. - Business Queries Script
-- =============================================================

-- ---------------------------------------------------------------
-- QUERY 1: Available stock per product
-- Business need: As inventory manager, I need to know the current
-- stock of each product to plan future purchases.
-- Logic: SUM(IN quantities) - SUM(OUT quantities) per product
-- ---------------------------------------------------------------
SELECT
    p.product_name                                        AS product,
    c.category_name                                       AS category,
    COALESCE(SUM(CASE WHEN im.movement_type = 'IN'  THEN im.quantity ELSE 0 END), 0)
        - COALESCE(SUM(CASE WHEN im.movement_type = 'OUT' THEN im.quantity ELSE 0 END), 0)
        AS available_stock
FROM riwi_products p
JOIN riwi_categories c ON c.category_id = p.category_id
LEFT JOIN riwi_inventory_movements im ON im.product_id = p.product_id
GROUP BY p.product_id, p.product_name, c.category_name
ORDER BY available_stock DESC;

-- ---------------------------------------------------------------
-- QUERY 2: Inventory movements with product and warehouse detail
-- Business need: As logistics supervisor, I need to know which
-- movements were made in each warehouse and which products were involved.
-- ---------------------------------------------------------------
SELECT
    im.movement_id,
    im.movement_date,
    im.movement_type,
    im.quantity,
    p.product_name,
    w.warehouse_name,
    wc.city_name   AS warehouse_city,
    po.purchase_order
FROM riwi_inventory_movements im
JOIN riwi_products   p  ON p.product_id   = im.product_id
JOIN riwi_warehouses w  ON w.warehouse_id = im.warehouse_id
JOIN riwi_cities     wc ON wc.city_id     = w.city_id
LEFT JOIN riwi_purchases po ON po.purchase_id = im.purchase_id
ORDER BY im.movement_date, w.warehouse_name;

-- ---------------------------------------------------------------
-- QUERY 3: Total purchased amount per supplier
-- Business need: As purchasing manager, I need to identify how
-- much has been bought from each supplier.
-- ---------------------------------------------------------------
SELECT
    s.supplier_name,
    sc.city_name            AS supplier_city,
    COUNT(pu.purchase_id)   AS total_orders,
    SUM(pu.quantity)        AS total_units_purchased,
    SUM(pu.quantity * pu.unit_price) AS total_amount_cop
FROM riwi_suppliers s
JOIN riwi_cities    sc ON sc.city_id    = s.city_id
JOIN riwi_purchases pu ON pu.supplier_id = s.supplier_id
GROUP BY s.supplier_id, s.supplier_name, sc.city_name
ORDER BY total_amount_cop DESC;

-- ---------------------------------------------------------------
-- QUERY 4: Number of movements registered per warehouse
-- Business need: As operations administrator, I need to know which
-- warehouses show the highest activity.
-- ---------------------------------------------------------------
SELECT
    w.warehouse_name,
    c.city_name         AS warehouse_city,
    COUNT(im.movement_id) AS total_movements,
    SUM(CASE WHEN im.movement_type = 'IN'  THEN 1 ELSE 0 END) AS in_movements,
    SUM(CASE WHEN im.movement_type = 'OUT' THEN 1 ELSE 0 END) AS out_movements
FROM riwi_warehouses w
JOIN riwi_cities c ON c.city_id = w.city_id
LEFT JOIN riwi_inventory_movements im ON im.warehouse_id = w.warehouse_id
GROUP BY w.warehouse_id, w.warehouse_name, c.city_name
ORDER BY total_movements DESC;

-- ---------------------------------------------------------------
-- QUERY 5: Product with the highest purchase volume
-- Business need: As analyst, I need to identify which product
-- generates the highest rotation within the organization.
-- ---------------------------------------------------------------
SELECT
    p.product_name,
    cat.category_name,
    SUM(pu.quantity)                        AS total_units_bought,
    SUM(pu.quantity * pu.unit_price)        AS total_value_cop
FROM riwi_products p
JOIN riwi_categories cat ON cat.category_id = p.category_id
JOIN riwi_purchases  pu  ON pu.product_id   = p.product_id
GROUP BY p.product_id, p.product_name, cat.category_name
ORDER BY total_units_bought DESC
LIMIT 1;

-- ---------------------------------------------------------------
-- QUERY 6: Total inventory value stored per warehouse
-- Business need: As operations manager, I need to know the economic
-- value of inventory distributed across each warehouse.
-- Logic: only IN movements contribute to stored value
-- ---------------------------------------------------------------
SELECT
    w.warehouse_name,
    c.city_name        AS warehouse_city,
    SUM(im.quantity * p.unit_price) AS total_inventory_value_cop
FROM riwi_warehouses w
JOIN riwi_cities c ON c.city_id = w.city_id
JOIN riwi_inventory_movements im ON im.warehouse_id = w.warehouse_id
JOIN riwi_products p ON p.product_id = im.product_id
WHERE im.movement_type = 'IN'
GROUP BY w.warehouse_id, w.warehouse_name, c.city_name
ORDER BY total_inventory_value_cop DESC;
