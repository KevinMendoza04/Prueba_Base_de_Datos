-- =============================================================
-- RiwiSupply S.A.S. - Database DDL Script
-- Database: bd_kevin_mendoza_micaela  <-- UPDATE WITH YOUR NAME
-- Engine: PostgreSQL
-- Author: Kevin Mendoza | Clan: Micaela
-- =============================================================

-- Create database (run separately as superuser if needed)
-- CREATE DATABASE bd_kevin_mendoza_micaela;

-- Drop tables in reverse dependency order (for re-runs)
DROP TABLE IF EXISTS riwi_inventory_movements CASCADE;
DROP TABLE IF EXISTS riwi_purchases           CASCADE;
DROP TABLE IF EXISTS riwi_products            CASCADE;
DROP TABLE IF EXISTS riwi_categories          CASCADE;
DROP TABLE IF EXISTS riwi_warehouses          CASCADE;
DROP TABLE IF EXISTS riwi_suppliers           CASCADE;
DROP TABLE IF EXISTS riwi_cities              CASCADE;

-- =============================================================
-- TABLE: riwi_cities
-- Stores unique city names to avoid redundancy across suppliers
-- and warehouses (3NF: removes transitive dependency on city name)
-- =============================================================
CREATE TABLE riwi_cities (
    city_id   SERIAL       PRIMARY KEY,
    city_name VARCHAR(100) NOT NULL UNIQUE
);

-- =============================================================
-- TABLE: riwi_categories
-- Stores product categories (1NF: atomic, deduplicated)
-- =============================================================
CREATE TABLE riwi_categories (
    category_id   SERIAL       PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE
);

-- =============================================================
-- TABLE: riwi_suppliers
-- Stores normalized supplier data
-- 3NF: city extracted to riwi_cities (city_name depends on city_id, not supplier)
-- =============================================================
CREATE TABLE riwi_suppliers (
    supplier_id   SERIAL       PRIMARY KEY,
    supplier_name VARCHAR(150) NOT NULL UNIQUE,
    city_id       INT          NOT NULL,
    CONSTRAINT fk_supplier_city FOREIGN KEY (city_id) REFERENCES riwi_cities(city_id)
);

-- =============================================================
-- TABLE: riwi_warehouses
-- Stores normalized warehouse data
-- 3NF: city extracted to riwi_cities
-- =============================================================
CREATE TABLE riwi_warehouses (
    warehouse_id   SERIAL       PRIMARY KEY,
    warehouse_name VARCHAR(150) NOT NULL UNIQUE,
    city_id        INT          NOT NULL,
    CONSTRAINT fk_warehouse_city FOREIGN KEY (city_id) REFERENCES riwi_cities(city_id)
);

-- =============================================================
-- TABLE: riwi_products
-- Stores normalized product data
-- 2NF: category extracted (no partial dependency on composite key)
-- 3NF: category_name depends on category_id, not product_id
-- =============================================================
CREATE TABLE riwi_products (
    product_id   SERIAL        PRIMARY KEY,
    product_name VARCHAR(150)  NOT NULL UNIQUE,
    unit_price   NUMERIC(12,2) NOT NULL CHECK (unit_price >= 0),
    category_id  INT           NOT NULL,
    CONSTRAINT fk_product_category FOREIGN KEY (category_id) REFERENCES riwi_categories(category_id)
);

-- =============================================================
-- TABLE: riwi_purchases
-- Stores purchase orders linking supplier and product
-- =============================================================
CREATE TABLE riwi_purchases (
    purchase_id    SERIAL       PRIMARY KEY,
    purchase_order VARCHAR(20)  NOT NULL UNIQUE,
    purchase_date  DATE         NOT NULL,
    supplier_id    INT          NOT NULL,
    product_id     INT          NOT NULL,
    quantity       INT          NOT NULL CHECK (quantity > 0),
    unit_price     NUMERIC(12,2) NOT NULL CHECK (unit_price >= 0),
    CONSTRAINT fk_purchase_supplier FOREIGN KEY (supplier_id) REFERENCES riwi_suppliers(supplier_id),
    CONSTRAINT fk_purchase_product  FOREIGN KEY (product_id)  REFERENCES riwi_products(product_id)
);

-- =============================================================
-- TABLE: riwi_inventory_movements
-- Records every IN/OUT movement per product/warehouse
-- =============================================================
CREATE TABLE riwi_inventory_movements (
    movement_id    SERIAL      PRIMARY KEY,
    movement_date  DATE        NOT NULL,
    movement_type  VARCHAR(3)  NOT NULL CHECK (movement_type IN ('IN', 'OUT')),
    quantity       INT         NOT NULL CHECK (quantity > 0),
    product_id     INT         NOT NULL,
    warehouse_id   INT         NOT NULL,
    purchase_id    INT,                          -- nullable: OUT movements may not have a PO
    CONSTRAINT fk_movement_product   FOREIGN KEY (product_id)   REFERENCES riwi_products(product_id),
    CONSTRAINT fk_movement_warehouse FOREIGN KEY (warehouse_id) REFERENCES riwi_warehouses(warehouse_id),
    CONSTRAINT fk_movement_purchase  FOREIGN KEY (purchase_id)  REFERENCES riwi_purchases(purchase_id)
);
