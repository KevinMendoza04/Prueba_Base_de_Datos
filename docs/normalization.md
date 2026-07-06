# Normalization Process – RiwiSupply S.A.S.

**Author:** Kevin Mendoza | **Clan:** Micaela

---

## 1. Initial Structure (Raw Data)

The Excel file contains a single flat table (`raw_data`) with **19 rows** and **11 columns**:

| Column | Type |
|---|---|
| MovementDate | Date |
| SupplierName | Text |
| SupplierCity | Text |
| Warehouse | Text |
| WarehouseCity | Text |
| ProductName | Text |
| Category | Text |
| Quantity | Integer |
| UnitPrice | Decimal |
| MovementType | Text (IN/OUT) |
| PurchaseOrder | Text |

---

## 2. Problems Identified

### Duplicate / inconsistent suppliers
| Raw value | Canonical value |
|---|---|
| `Aceros del Norte S.A.S` | Aceros del Norte S.A.S |
| `Aceros del Norte` | Aceros del Norte S.A.S |
| `ACEROS NORTE` | Aceros del Norte S.A.S |
| `Industriales SAS` | Industriales S.A.S |
| `Industriales S.A.S` | Industriales S.A.S |
| `INDUSTRIALES SAS` | Industriales S.A.S |

### Inconsistent city names
| Raw value | Canonical value |
|---|---|
| `Barranquila` | Barranquilla |
| `B/quilla` | Barranquilla |
| `Sta Marta` | Santa Marta |
| `Ctg` | Cartagena |

### Inconsistent warehouse names
| Raw value | Canonical value |
|---|---|
| `Bod. Central` | Bodega Central |
| `Bodega Central` | Bodega Central |

### Inconsistent product names
| Raw value | Canonical value |
|---|---|
| `Disco de Corte 4.5` | Disco de Corte 4.5 |
| `Disco Corte 4.5` | Disco de Corte 4.5 |
| `Guante Nitrilo` | Guante de Nitrilo |
| `Guantes de Nitrilo` | Guante de Nitrilo |
| `Electrodo E6013` | Electrodo E6013 |
| `Soldadura E6013` | Electrodo E6013 |

### Inconsistent category names
| Raw value | Canonical value |
|---|---|
| `Herramienta` | Herramienta |
| `Herramientas` | Herramienta |
| `Consumible` | Consumible |
| `Consumibles` | Consumible |
| `EPP` | EPP |
| `Elementos Protección` | EPP |

---

## 3. First Normal Form (1NF)

**Rule:** Each column must contain atomic (indivisible) values. No repeating groups.

**Applied:**
- All columns already hold single values — no multi-valued fields exist.
- Corrected spelling inconsistencies so each entity maps to exactly one value.
- Added a primary key to each resulting table (`_id SERIAL PRIMARY KEY`).

**Result:** Flat table is valid for 1NF after deduplication of values.

---

## 4. Second Normal Form (2NF)

**Rule:** Must be in 1NF and every non-key attribute must depend on the **whole** primary key (eliminates partial dependencies — relevant when composite keys exist).

**Applied:**
- The original flat table has no explicit composite key, but the data implies one: `(PurchaseOrder, ProductName, Warehouse)`.
- `Category` depends only on `ProductName`, not on the full key → extracted to `riwi_categories`.
- `SupplierCity` depends only on `SupplierName` → city will be further separated in 3NF.
- `WarehouseCity` depends only on `Warehouse` → same treatment.

**Tables created at this stage:**
- `riwi_categories (category_id, category_name)`
- `riwi_products (product_id, product_name, unit_price, category_id)`

---

## 5. Third Normal Form (3NF)

**Rule:** Must be in 2NF and there must be no **transitive dependencies** (non-key attribute depending on another non-key attribute).

**Applied:**
- `SupplierCity` is not a property of the movement — it is a property of the supplier. And `city_name` is not a property of the supplier — it stands on its own.  
  → `SupplierCity` → extracted to `riwi_cities`; `riwi_suppliers` references `city_id`.
- Same logic for `WarehouseCity` → `riwi_warehouses` references `city_id`.
- `PurchaseOrder` details (date, supplier, product, quantity, price) extracted to `riwi_purchases`.
- Movement data (date, type, quantity, warehouse) extracted to `riwi_inventory_movements`.

**Tables created at this stage:**
- `riwi_cities (city_id, city_name)`
- `riwi_suppliers (supplier_id, supplier_name, city_id)`
- `riwi_warehouses (warehouse_id, warehouse_name, city_id)`
- `riwi_purchases (purchase_id, purchase_order, purchase_date, supplier_id, product_id, quantity, unit_price)`
- `riwi_inventory_movements (movement_id, movement_date, movement_type, quantity, product_id, warehouse_id, purchase_id)`

---

## 6. Final Normalized Structure (3NF)

```
riwi_cities
  city_id (PK), city_name (UNIQUE NOT NULL)

riwi_categories
  category_id (PK), category_name (UNIQUE NOT NULL)

riwi_suppliers
  supplier_id (PK), supplier_name (UNIQUE NOT NULL), city_id (FK → riwi_cities)

riwi_warehouses
  warehouse_id (PK), warehouse_name (UNIQUE NOT NULL), city_id (FK → riwi_cities)

riwi_products
  product_id (PK), product_name (UNIQUE NOT NULL), unit_price (NOT NULL), category_id (FK → riwi_categories)

riwi_purchases
  purchase_id (PK), purchase_order (UNIQUE NOT NULL), purchase_date (NOT NULL),
  supplier_id (FK → riwi_suppliers), product_id (FK → riwi_products),
  quantity (NOT NULL), unit_price (NOT NULL)

riwi_inventory_movements
  movement_id (PK), movement_date (NOT NULL), movement_type IN('IN','OUT'),
  quantity (NOT NULL), product_id (FK → riwi_products),
  warehouse_id (FK → riwi_warehouses), purchase_id (FK → riwi_purchases)
```

---

## 7. Justification Summary

| Decision | Reason |
|---|---|
| Separate `riwi_cities` table | City names were repeated across suppliers and warehouses. Centralizing them eliminates redundancy (3NF). |
| Separate `riwi_categories` table | Category depends on product, not on movement. Separating avoids update anomalies (2NF → 3NF). |
| Separate `riwi_purchases` table | Purchase order data (date, supplier, product, price) was repeated across movement rows — extracted to avoid duplication (3NF). |
| `UNIQUE` on names | Prevents re-introduction of duplicates like those found in the raw data. |
| `CHECK` on movement_type | Restricts values to 'IN'/'OUT', enforcing domain integrity. |
| `purchase_id` nullable in movements | OUT movements may not always be tied to a specific PO; the FK is optional to allow this. |
