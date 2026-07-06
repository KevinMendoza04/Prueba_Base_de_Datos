-- =============================================================
-- RiwiSupply S.A.S. - Data Load Script (DML)
-- Normalized data extracted and cleaned from Dataset_RiwiSupply
-- =============================================================

-- ---------------------------------------------------------------
-- 1. CITIES (normalized from SupplierCity + WarehouseCity)
--    Raw inconsistencies fixed:
--      'Barranquila' / 'B/quilla'  → 'Barranquilla'
--      'Sta Marta'                 → 'Santa Marta'
--      'Ctg'                       → 'Cartagena'
-- ---------------------------------------------------------------
INSERT INTO riwi_cities (city_name) VALUES
    ('Barranquilla'),
    ('Cartagena'),
    ('Santa Marta');

-- ---------------------------------------------------------------
-- 2. CATEGORIES (normalized from Category column)
--    Raw inconsistencies fixed:
--      'Herramientas' / 'Herramienta'       → 'Herramienta'
--      'Consumibles' / 'Consumible'          → 'Consumible'
--      'EPP' / 'Elementos Protección'        → 'EPP'
-- ---------------------------------------------------------------
INSERT INTO riwi_categories (category_name) VALUES
    ('Herramienta'),
    ('Consumible'),
    ('EPP');

-- ---------------------------------------------------------------
-- 3. SUPPLIERS (normalized from SupplierName + SupplierCity)
--    Raw inconsistencies fixed:
--      'Aceros del Norte S.A.S' / 'Aceros del Norte' / 'ACEROS NORTE' → 'Aceros del Norte S.A.S'
--      'Industriales SAS' / 'Industriales S.A.S' / 'INDUSTRIALES SAS' → 'Industriales S.A.S'
--      'Suministros Global SAS'                                        → 'Suministros Global S.A.S'
-- ---------------------------------------------------------------
INSERT INTO riwi_suppliers (supplier_name, city_id) VALUES
    ('Aceros del Norte S.A.S',    (SELECT city_id FROM riwi_cities WHERE city_name = 'Cartagena')),
    ('Industriales S.A.S',        (SELECT city_id FROM riwi_cities WHERE city_name = 'Barranquilla')),
    ('Suministros Global S.A.S',  (SELECT city_id FROM riwi_cities WHERE city_name = 'Santa Marta'));

-- ---------------------------------------------------------------
-- 4. WAREHOUSES (normalized from Warehouse + WarehouseCity)
--    Raw inconsistencies fixed:
--      'Bod. Central' / 'Bodega Central' → 'Bodega Central'
-- ---------------------------------------------------------------
INSERT INTO riwi_warehouses (warehouse_name, city_id) VALUES
    ('Bodega Costa',            (SELECT city_id FROM riwi_cities WHERE city_name = 'Santa Marta')),
    ('Bodega Central',          (SELECT city_id FROM riwi_cities WHERE city_name = 'Barranquilla')),
    ('Centro Logistico Norte',  (SELECT city_id FROM riwi_cities WHERE city_name = 'Cartagena'));

-- ---------------------------------------------------------------
-- 5. PRODUCTS (normalized from ProductName + Category + UnitPrice)
--    Raw inconsistencies fixed:
--      'Disco de Corte 4.5' / 'Disco Corte 4.5'       → 'Disco de Corte 4.5'
--      'Guante Nitrilo' / 'Guantes de Nitrilo'         → 'Guante de Nitrilo'
--      'Electrodo E6013' / 'Soldadura E6013'            → 'Electrodo E6013'
--    Unit price: representative average per product used
-- ---------------------------------------------------------------
INSERT INTO riwi_products (product_name, unit_price, category_id) VALUES
    ('Disco de Corte 4.5',  88512.00, (SELECT category_id FROM riwi_categories WHERE category_name = 'Herramienta')),
    ('Electrodo E6013',     43746.00, (SELECT category_id FROM riwi_categories WHERE category_name = 'Consumible')),
    ('Guante de Nitrilo',   39944.00, (SELECT category_id FROM riwi_categories WHERE category_name = 'EPP')),
    ('Casco Industrial',   108802.00, (SELECT category_id FROM riwi_categories WHERE category_name = 'EPP'));

-- ---------------------------------------------------------------
-- 6. PURCHASES (from PurchaseOrder + SupplierName + ProductName)
--    Each unique PO maps to one supplier + one product
-- ---------------------------------------------------------------
INSERT INTO riwi_purchases (purchase_order, purchase_date, supplier_id, product_id, quantity, unit_price) VALUES
    ('PO-1009', '2026-02-02',
        (SELECT supplier_id FROM riwi_suppliers WHERE supplier_name = 'Suministros Global S.A.S'),
        (SELECT product_id  FROM riwi_products  WHERE product_name  = 'Electrodo E6013'), 87, 123108.00),

    ('PO-1022', '2026-01-01',
        (SELECT supplier_id FROM riwi_suppliers WHERE supplier_name = 'Industriales S.A.S'),
        (SELECT product_id  FROM riwi_products  WHERE product_name  = 'Guante de Nitrilo'), 70, 14290.00),

    ('PO-1023', '2026-03-19',
        (SELECT supplier_id FROM riwi_suppliers WHERE supplier_name = 'Aceros del Norte S.A.S'),
        (SELECT product_id  FROM riwi_products  WHERE product_name  = 'Disco de Corte 4.5'), 199, 118291.00),

    ('PO-1029', '2026-01-25',
        (SELECT supplier_id FROM riwi_suppliers WHERE supplier_name = 'Industriales S.A.S'),
        (SELECT product_id  FROM riwi_products  WHERE product_name  = 'Guante de Nitrilo'), 131, 71980.00),

    ('PO-1032', '2026-04-17',
        (SELECT supplier_id FROM riwi_suppliers WHERE supplier_name = 'Suministros Global S.A.S'),
        (SELECT product_id  FROM riwi_products  WHERE product_name  = 'Guante de Nitrilo'), 185, 123653.00),

    ('PO-1034', '2026-04-26',
        (SELECT supplier_id FROM riwi_suppliers WHERE supplier_name = 'Industriales S.A.S'),
        (SELECT product_id  FROM riwi_products  WHERE product_name  = 'Disco de Corte 4.5'), 61, 136736.00),

    ('PO-1035', '2026-04-13',
        (SELECT supplier_id FROM riwi_suppliers WHERE supplier_name = 'Industriales S.A.S'),
        (SELECT product_id  FROM riwi_products  WHERE product_name  = 'Guante de Nitrilo'), 119, 23022.00),

    ('PO-1036', '2026-03-11',
        (SELECT supplier_id FROM riwi_suppliers WHERE supplier_name = 'Aceros del Norte S.A.S'),
        (SELECT product_id  FROM riwi_products  WHERE product_name  = 'Electrodo E6013'), 78, 37943.00),

    ('PO-1040', '2026-05-23',
        (SELECT supplier_id FROM riwi_suppliers WHERE supplier_name = 'Aceros del Norte S.A.S'),
        (SELECT product_id  FROM riwi_products  WHERE product_name  = 'Guante de Nitrilo'), 175, 39944.00),

    ('PO-1041', '2026-02-14',
        (SELECT supplier_id FROM riwi_suppliers WHERE supplier_name = 'Aceros del Norte S.A.S'),
        (SELECT product_id  FROM riwi_products  WHERE product_name  = 'Electrodo E6013'), 27, 35506.00),

    ('PO-1043', '2026-03-03',
        (SELECT supplier_id FROM riwi_suppliers WHERE supplier_name = 'Industriales S.A.S'),
        (SELECT product_id  FROM riwi_products  WHERE product_name  = 'Disco de Corte 4.5'), 169, 18022.00),

    ('PO-1049', '2026-04-01',
        (SELECT supplier_id FROM riwi_suppliers WHERE supplier_name = 'Aceros del Norte S.A.S'),
        (SELECT product_id  FROM riwi_products  WHERE product_name  = 'Disco de Corte 4.5'), 148, 115388.00),

    ('PO-1059', '2026-01-20',
        (SELECT supplier_id FROM riwi_suppliers WHERE supplier_name = 'Aceros del Norte S.A.S'),
        (SELECT product_id  FROM riwi_products  WHERE product_name  = 'Electrodo E6013'), 33, 43746.00),

    ('PO-1075', '2026-02-16',
        (SELECT supplier_id FROM riwi_suppliers WHERE supplier_name = 'Aceros del Norte S.A.S'),
        (SELECT product_id  FROM riwi_products  WHERE product_name  = 'Guante de Nitrilo'), 160, 117524.00),

    ('PO-1083', '2026-03-21',
        (SELECT supplier_id FROM riwi_suppliers WHERE supplier_name = 'Aceros del Norte S.A.S'),
        (SELECT product_id  FROM riwi_products  WHERE product_name  = 'Casco Industrial'), 192, 108802.00),

    ('PO-1091', '2026-02-28',
        (SELECT supplier_id FROM riwi_suppliers WHERE supplier_name = 'Industriales S.A.S'),
        (SELECT product_id  FROM riwi_products  WHERE product_name  = 'Electrodo E6013'), 40, 139836.00),

    ('PO-1094', '2026-03-12',
        (SELECT supplier_id FROM riwi_suppliers WHERE supplier_name = 'Industriales S.A.S'),
        (SELECT product_id  FROM riwi_products  WHERE product_name  = 'Disco de Corte 4.5'), 124, 52910.00);

-- ---------------------------------------------------------------
-- 7. INVENTORY MOVEMENTS
--    Mapped to normalized products, warehouses and purchases
-- ---------------------------------------------------------------
INSERT INTO riwi_inventory_movements (movement_date, movement_type, quantity, product_id, warehouse_id, purchase_id) VALUES
    -- Row 0: OUT PO-1049 Disco de Corte 4.5 | Bodega Costa (Santa Marta)
    ('2026-04-01', 'OUT', 148,
        (SELECT product_id  FROM riwi_products   WHERE product_name  = 'Disco de Corte 4.5'),
        (SELECT warehouse_id FROM riwi_warehouses WHERE warehouse_name = 'Bodega Costa'),
        (SELECT purchase_id FROM riwi_purchases  WHERE purchase_order = 'PO-1049')),

    -- Row 1: IN PO-1041 Electrodo E6013 | Bodega Costa
    ('2026-02-14', 'IN', 27,
        (SELECT product_id  FROM riwi_products   WHERE product_name  = 'Electrodo E6013'),
        (SELECT warehouse_id FROM riwi_warehouses WHERE warehouse_name = 'Bodega Costa'),
        (SELECT purchase_id FROM riwi_purchases  WHERE purchase_order = 'PO-1041')),

    -- Row 2: IN PO-1022 Guante de Nitrilo | Bodega Costa
    ('2026-01-01', 'IN', 70,
        (SELECT product_id  FROM riwi_products   WHERE product_name  = 'Guante de Nitrilo'),
        (SELECT warehouse_id FROM riwi_warehouses WHERE warehouse_name = 'Bodega Costa'),
        (SELECT purchase_id FROM riwi_purchases  WHERE purchase_order = 'PO-1022')),

    -- Row 3: IN PO-1075 Guante de Nitrilo | Centro Logistico Norte
    ('2026-02-16', 'IN', 160,
        (SELECT product_id  FROM riwi_products   WHERE product_name  = 'Guante de Nitrilo'),
        (SELECT warehouse_id FROM riwi_warehouses WHERE warehouse_name = 'Centro Logistico Norte'),
        (SELECT purchase_id FROM riwi_purchases  WHERE purchase_order = 'PO-1075')),

    -- Row 4: OUT PO-1091 Electrodo E6013 | Bodega Central
    ('2026-02-28', 'OUT', 40,
        (SELECT product_id  FROM riwi_products   WHERE product_name  = 'Electrodo E6013'),
        (SELECT warehouse_id FROM riwi_warehouses WHERE warehouse_name = 'Bodega Central'),
        (SELECT purchase_id FROM riwi_purchases  WHERE purchase_order = 'PO-1091')),

    -- Row 5: OUT PO-1041 Disco de Corte 4.5 | Bodega Central
    ('2026-03-06', 'OUT', 130,
        (SELECT product_id  FROM riwi_products   WHERE product_name  = 'Disco de Corte 4.5'),
        (SELECT warehouse_id FROM riwi_warehouses WHERE warehouse_name = 'Bodega Central'),
        (SELECT purchase_id FROM riwi_purchases  WHERE purchase_order = 'PO-1041')),

    -- Row 6: OUT PO-1059 Electrodo E6013 | Bodega Central
    ('2026-01-20', 'OUT', 33,
        (SELECT product_id  FROM riwi_products   WHERE product_name  = 'Electrodo E6013'),
        (SELECT warehouse_id FROM riwi_warehouses WHERE warehouse_name = 'Bodega Central'),
        (SELECT purchase_id FROM riwi_purchases  WHERE purchase_order = 'PO-1059')),

    -- Row 7: OUT PO-1035 Guante de Nitrilo | Bodega Costa
    ('2026-04-13', 'OUT', 119,
        (SELECT product_id  FROM riwi_products   WHERE product_name  = 'Guante de Nitrilo'),
        (SELECT warehouse_id FROM riwi_warehouses WHERE warehouse_name = 'Bodega Costa'),
        (SELECT purchase_id FROM riwi_purchases  WHERE purchase_order = 'PO-1035')),

    -- Row 8: IN PO-1032 Guante de Nitrilo | Bodega Central
    ('2026-04-17', 'IN', 185,
        (SELECT product_id  FROM riwi_products   WHERE product_name  = 'Guante de Nitrilo'),
        (SELECT warehouse_id FROM riwi_warehouses WHERE warehouse_name = 'Bodega Central'),
        (SELECT purchase_id FROM riwi_purchases  WHERE purchase_order = 'PO-1032')),

    -- Row 9: OUT PO-1009 Electrodo E6013 | Bodega Central
    ('2026-02-02', 'OUT', 87,
        (SELECT product_id  FROM riwi_products   WHERE product_name  = 'Electrodo E6013'),
        (SELECT warehouse_id FROM riwi_warehouses WHERE warehouse_name = 'Bodega Central'),
        (SELECT purchase_id FROM riwi_purchases  WHERE purchase_order = 'PO-1009')),

    -- Row 10: IN PO-1040 Guante de Nitrilo | Bodega Costa
    ('2026-05-23', 'IN', 175,
        (SELECT product_id  FROM riwi_products   WHERE product_name  = 'Guante de Nitrilo'),
        (SELECT warehouse_id FROM riwi_warehouses WHERE warehouse_name = 'Bodega Costa'),
        (SELECT purchase_id FROM riwi_purchases  WHERE purchase_order = 'PO-1040')),

    -- Row 11: OUT PO-1023 Disco de Corte 4.5 | Bodega Central
    ('2026-03-19', 'OUT', 199,
        (SELECT product_id  FROM riwi_products   WHERE product_name  = 'Disco de Corte 4.5'),
        (SELECT warehouse_id FROM riwi_warehouses WHERE warehouse_name = 'Bodega Central'),
        (SELECT purchase_id FROM riwi_purchases  WHERE purchase_order = 'PO-1023')),

    -- Row 12: OUT PO-1029 Guante de Nitrilo | Centro Logistico Norte
    ('2026-01-25', 'OUT', 131,
        (SELECT product_id  FROM riwi_products   WHERE product_name  = 'Guante de Nitrilo'),
        (SELECT warehouse_id FROM riwi_warehouses WHERE warehouse_name = 'Centro Logistico Norte'),
        (SELECT purchase_id FROM riwi_purchases  WHERE purchase_order = 'PO-1029')),

    -- Row 13: OUT PO-1035 Disco de Corte 4.5 | Bodega Costa
    ('2026-03-15', 'OUT', 134,
        (SELECT product_id  FROM riwi_products   WHERE product_name  = 'Disco de Corte 4.5'),
        (SELECT warehouse_id FROM riwi_warehouses WHERE warehouse_name = 'Bodega Costa'),
        (SELECT purchase_id FROM riwi_purchases  WHERE purchase_order = 'PO-1035')),

    -- Row 14: IN PO-1094 Disco de Corte 4.5 | Bodega Central
    ('2026-03-12', 'IN', 124,
        (SELECT product_id  FROM riwi_products   WHERE product_name  = 'Disco de Corte 4.5'),
        (SELECT warehouse_id FROM riwi_warehouses WHERE warehouse_name = 'Bodega Central'),
        (SELECT purchase_id FROM riwi_purchases  WHERE purchase_order = 'PO-1094')),

    -- Row 15: IN PO-1034 Disco de Corte 4.5 | Bodega Central
    ('2026-04-26', 'IN', 61,
        (SELECT product_id  FROM riwi_products   WHERE product_name  = 'Disco de Corte 4.5'),
        (SELECT warehouse_id FROM riwi_warehouses WHERE warehouse_name = 'Bodega Central'),
        (SELECT purchase_id FROM riwi_purchases  WHERE purchase_order = 'PO-1034')),

    -- Row 16: OUT PO-1043 Disco de Corte 4.5 | Centro Logistico Norte
    ('2026-03-03', 'OUT', 169,
        (SELECT product_id  FROM riwi_products   WHERE product_name  = 'Disco de Corte 4.5'),
        (SELECT warehouse_id FROM riwi_warehouses WHERE warehouse_name = 'Centro Logistico Norte'),
        (SELECT purchase_id FROM riwi_purchases  WHERE purchase_order = 'PO-1043')),

    -- Row 17: OUT PO-1083 Casco Industrial | Bodega Costa
    ('2026-03-21', 'OUT', 192,
        (SELECT product_id  FROM riwi_products   WHERE product_name  = 'Casco Industrial'),
        (SELECT warehouse_id FROM riwi_warehouses WHERE warehouse_name = 'Bodega Costa'),
        (SELECT purchase_id FROM riwi_purchases  WHERE purchase_order = 'PO-1083')),

    -- Row 18: OUT PO-1036 Electrodo E6013 | Centro Logistico Norte
    ('2026-03-11', 'OUT', 78,
        (SELECT product_id  FROM riwi_products   WHERE product_name  = 'Electrodo E6013'),
        (SELECT warehouse_id FROM riwi_warehouses WHERE warehouse_name = 'Centro Logistico Norte'),
        (SELECT purchase_id FROM riwi_purchases  WHERE purchase_order = 'PO-1036'));
