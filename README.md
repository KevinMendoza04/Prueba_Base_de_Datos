# RiwiSupply S.A.S. — Relational Database Project

## Project Description

RiwiSupply S.A.S. is a company dedicated to the commercialization and distribution of industrial supplies nationwide. This project centralizes all operational data — previously managed in a single inconsistent Excel file — into a normalized relational database. The solution covers suppliers, products, categories, warehouses, purchase orders, and inventory movements.

---

## Technologies Used

- **PostgreSQL 16** — relational database engine
- **Docker** — containerized database environment
- **SQL** — DDL, DML, and query scripts
- **Python + pandas** — data analysis and exploration of the Excel source file
- **Draw.io** — Entity-Relationship Model diagram

---

## Database Engine

**PostgreSQL 16**  
Database name: `bd_kevin_mendoza_micaela`  
Connection: `host=127.0.0.1 port=5433 user=moises password=123456`

---

## Normalization Process

### Initial Structure
Single flat table with 19 rows and 11 columns mixing supplier, warehouse, product, category, purchase order, and movement data.

### Problems Identified
- Suppliers duplicated with 3 different name formats (e.g., `Aceros del Norte S.A.S`, `Aceros del Norte`, `ACEROS NORTE`)
- Cities written inconsistently (`Barranquila`, `B/quilla`, `Sta Marta`, `Ctg`)
- Warehouses with abbreviated names (`Bod. Central` vs `Bodega Central`)
- Products with variant names (`Disco Corte 4.5` / `Disco de Corte 4.5`, `Guante Nitrilo` / `Guantes de Nitrilo`)
- Categories inconsistent (`Herramienta` / `Herramientas`, `Consumible` / `Consumibles`, `EPP` / `Elementos Protección`)

### 1NF — First Normal Form
- All columns contain atomic, single values.
- No repeating groups exist.
- Spelling inconsistencies corrected so each entity maps to one canonical value.
- Primary key added to each table.

### 2NF — Second Normal Form
- Eliminated partial dependencies.
- `Category` depends only on `ProductName` → extracted to `riwi_categories`.
- `UnitPrice` stored at product level and also recorded per purchase to preserve historical pricing.

### 3NF — Third Normal Form
- Eliminated transitive dependencies.
- `SupplierCity` and `WarehouseCity` moved to `riwi_cities` — city name does not depend on supplier or warehouse ID.
- `PurchaseOrder` details (date, supplier, product, price) extracted to `riwi_purchases`.
- Movement data extracted to `riwi_inventory_movements`.

Full normalization detail: see [`docs/normalization.md`](docs/normalization.md)

---

## Database Structure

```
riwi_cities              → city_id (PK), city_name
riwi_categories          → category_id (PK), category_name
riwi_suppliers           → supplier_id (PK), supplier_name, city_id (FK)
riwi_warehouses          → warehouse_id (PK), warehouse_name, city_id (FK)
riwi_products            → product_id (PK), product_name, unit_price, category_id (FK)
riwi_purchases           → purchase_id (PK), purchase_order, purchase_date,
                           supplier_id (FK), product_id (FK), quantity, unit_price
riwi_inventory_movements → movement_id (PK), movement_date, movement_type,
                           quantity, product_id (FK), warehouse_id (FK), purchase_id (FK)
```

**All table and column names are in English and use the `riwi_` prefix.**

---

## Entity Relationship Model

The ERD is located at `docs/MER_description.md` and includes the Draw.io XML to reproduce the diagram.

Entities: `riwi_cities`, `riwi_categories`, `riwi_suppliers`, `riwi_warehouses`, `riwi_products`, `riwi_purchases`, `riwi_inventory_movements`

Key relationships:
- A **city** can have many **suppliers** and many **warehouses** (1:N)
- A **category** groups many **products** (1:N)
- A **supplier** can have many **purchases** (1:N)
- A **product** can appear in many **purchases** and many **movements** (1:N)
- A **warehouse** can have many **movements** (1:N)
- A **purchase** can be linked to many **movements** (1:N, optional)

---

## Instructions to Create the Database

### Prerequisites
- Docker running with the PostgreSQL container active
- `psql` client installed

### Steps

```bash
# 1. Create the database
PGPASSWORD='123456' psql -h 127.0.0.1 -p 5433 -U moises -d micaela \
  -c "CREATE DATABASE bd_kevin_mendoza_micaela OWNER moises;"

# 2. Run the DDL script (creates all tables, PKs, FKs, constraints)
PGPASSWORD='123456' psql -h 127.0.0.1 -p 5433 -U moises \
  -d bd_kevin_mendoza_micaela -f sql/01_DDL.sql

# 3. Load the normalized data
PGPASSWORD='123456' psql -h 127.0.0.1 -p 5433 -U moises \
  -d bd_kevin_mendoza_micaela -f sql/02_DML_load.sql
```

---

## Instructions to Load Data

Data is loaded via SQL script `sql/02_DML_load.sql` in the following order (respecting FK dependencies):

1. `riwi_cities` — 3 records
2. `riwi_categories` — 3 records
3. `riwi_suppliers` — 3 records
4. `riwi_warehouses` — 3 records
5. `riwi_products` — 4 records
6. `riwi_purchases` — 17 records
7. `riwi_inventory_movements` — 19 records

All values were manually normalized from the raw Excel file. The strategy chosen was **SQL INSERT scripts** because the dataset is small (19 rows) and the normalization process required manual data cleaning before loading. Each INSERT uses subqueries to resolve FK values by name, making the script readable and reproducible without needing to know internal IDs.

```bash
PGPASSWORD='123456' psql -h 127.0.0.1 -p 5433 -U moises \
  -d bd_kevin_mendoza_micaela -f sql/02_DML_load.sql
```

---

## SQL Query Explanations

### Query 1 — Available stock per product
**File:** `sql/04_queries.sql`  
Calculates current stock as `SUM(IN quantities) - SUM(OUT quantities)` grouped by product. Uses `LEFT JOIN` to include products with zero movements. Answers the inventory manager's need to plan future purchases.

### Query 2 — Inventory movements with product and warehouse detail
Lists every movement with its product name, warehouse, city, and purchase order. Ordered by date and warehouse. Answers the logistics supervisor's need to track activity per warehouse.

### Query 3 — Total purchased amount per supplier
Groups purchases by supplier showing order count, total units, and total value in COP. Ordered by value descending. Answers the purchasing manager's need to evaluate supplier spend.

### Query 4 — Number of movements registered per warehouse
Counts total, IN, and OUT movements per warehouse. Identifies the most active warehouses. Answers the operations administrator's need.

### Query 5 — Product with highest purchase volume
Returns the single product with the highest total units purchased across all orders. Answers the analyst's need to identify the highest-rotation product.

### Query 6 — Total inventory value stored per warehouse
Calculates the economic value of all IN movements per warehouse using `quantity × unit_price`. Only entry movements are considered since they represent stored goods. Answers the operations manager's financial reporting need.

---

## DML Operations

**File:** `sql/03_DML_operations.sql`

| Operation | Description |
|---|---|
| INSERT | Adds new city (Medellín), new supplier (Metalmecánica del Valle S.A.S), and new product (Taladro Percutor 1/2") |
| UPDATE | Changes the city of supplier 'Industriales S.A.S' |
| DELETE | Removes the new product only if it has no associated inventory movements (safe delete) |

---

## Developer Information

| Field | Value |
|---|---|
| Full name | Kevin Mendoza |
| Clan | Micaela |
| GitHub | https://github.com/KevinMendoza04/Prueba_Base_de_Datos |
