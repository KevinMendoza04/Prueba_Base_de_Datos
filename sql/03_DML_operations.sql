-- =============================================================
-- RiwiSupply S.A.S. - DML Operations Script
-- INSERT / UPDATE / DELETE as required by the assessment
-- =============================================================

-- ---------------------------------------------------------------
-- OPERATION 1: INSERT - Register a new supplier and associated product
-- ---------------------------------------------------------------

-- Step 1a: Insert new city (if it does not already exist)
INSERT INTO riwi_cities (city_name)
VALUES ('Medellín')
ON CONFLICT (city_name) DO NOTHING;

-- Step 1b: Insert new supplier linked to the city
INSERT INTO riwi_suppliers (supplier_name, city_id)
VALUES (
    'Metalmecánica del Valle S.A.S',
    (SELECT city_id FROM riwi_cities WHERE city_name = 'Medellín')
);

-- Step 1c: Insert new product linked to an existing category
INSERT INTO riwi_products (product_name, unit_price, category_id)
VALUES (
    'Taladro Percutor 1/2"',
    250000.00,
    (SELECT category_id FROM riwi_categories WHERE category_name = 'Herramienta')
);

-- ---------------------------------------------------------------
-- OPERATION 2: UPDATE - Modify information of an existing supplier
-- ---------------------------------------------------------------

-- Update the city of supplier 'Industriales S.A.S' from Barranquilla to Cartagena
UPDATE riwi_suppliers
SET city_id = (SELECT city_id FROM riwi_cities WHERE city_name = 'Cartagena')
WHERE supplier_name = 'Industriales S.A.S';

-- ---------------------------------------------------------------
-- OPERATION 3: DELETE - Remove a product that has no associated movements
-- ---------------------------------------------------------------

-- Safe delete: only removes if the product has no inventory movements
-- 'Taladro Percutor 1/2"' was just inserted and has no movements
DELETE FROM riwi_products
WHERE product_name = 'Taladro Percutor 1/2"'
  AND product_id NOT IN (
      SELECT DISTINCT product_id
      FROM riwi_inventory_movements
  );

-- Verification: the following query should return 0 rows after the DELETE
-- SELECT * FROM riwi_products WHERE product_name = 'Taladro Percutor 1/2"';
