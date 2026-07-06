# Entity-Relationship Model – RiwiSupply S.A.S.

## Instructions to draw in Draw.io / Lucidchart

Import the XML below into draw.io (File → Import from → XML) to get the full ERD.

---

## Entities, Attributes and Relationships

### ENTITIES

**riwi_cities**
- 🔑 city_id (PK, SERIAL)
- city_name (VARCHAR 100, UNIQUE, NOT NULL)

**riwi_categories**
- 🔑 category_id (PK, SERIAL)
- category_name (VARCHAR 100, UNIQUE, NOT NULL)

**riwi_suppliers**
- 🔑 supplier_id (PK, SERIAL)
- supplier_name (VARCHAR 150, UNIQUE, NOT NULL)
- 🔗 city_id (FK → riwi_cities)

**riwi_warehouses**
- 🔑 warehouse_id (PK, SERIAL)
- warehouse_name (VARCHAR 150, UNIQUE, NOT NULL)
- 🔗 city_id (FK → riwi_cities)

**riwi_products**
- 🔑 product_id (PK, SERIAL)
- product_name (VARCHAR 150, UNIQUE, NOT NULL)
- unit_price (NUMERIC 12,2, NOT NULL)
- 🔗 category_id (FK → riwi_categories)

**riwi_purchases**
- 🔑 purchase_id (PK, SERIAL)
- purchase_order (VARCHAR 20, UNIQUE, NOT NULL)
- purchase_date (DATE, NOT NULL)
- quantity (INT, NOT NULL)
- unit_price (NUMERIC 12,2, NOT NULL)
- 🔗 supplier_id (FK → riwi_suppliers)
- 🔗 product_id (FK → riwi_products)

**riwi_inventory_movements**
- 🔑 movement_id (PK, SERIAL)
- movement_date (DATE, NOT NULL)
- movement_type (VARCHAR 3, CHECK IN/OUT, NOT NULL)
- quantity (INT, NOT NULL)
- 🔗 product_id (FK → riwi_products)
- 🔗 warehouse_id (FK → riwi_warehouses)
- 🔗 purchase_id (FK → riwi_purchases, nullable)

---

### RELATIONSHIPS AND CARDINALITIES

| Relationship | Cardinality | Description |
|---|---|---|
| riwi_cities → riwi_suppliers | 1:N | A city can have many suppliers |
| riwi_cities → riwi_warehouses | 1:N | A city can have many warehouses |
| riwi_categories → riwi_products | 1:N | A category groups many products |
| riwi_suppliers → riwi_purchases | 1:N | A supplier can have many purchases |
| riwi_products → riwi_purchases | 1:N | A product can appear in many purchases |
| riwi_products → riwi_inventory_movements | 1:N | A product can have many movements |
| riwi_warehouses → riwi_inventory_movements | 1:N | A warehouse can have many movements |
| riwi_purchases → riwi_inventory_movements | 1:N | A purchase can have many movements (optional) |

---

## Draw.io XML (paste at drawio.com → Extras → Edit Diagram)

```xml
<mxGraphModel>
  <root>
    <mxCell id="0"/><mxCell id="1" parent="0"/>

    <!-- riwi_cities -->
    <mxCell id="2" value="riwi_cities&#xa;──────────&#xa;🔑 city_id PK&#xa;city_name UNIQUE" style="rounded=1;fillColor=#dae8fc;strokeColor=#6c8ebf;fontStyle=1;align=left;" vertex="1" parent="1">
      <mxGeometry x="20" y="200" width="180" height="90" as="geometry"/>
    </mxCell>

    <!-- riwi_categories -->
    <mxCell id="3" value="riwi_categories&#xa;──────────&#xa;🔑 category_id PK&#xa;category_name UNIQUE" style="rounded=1;fillColor=#d5e8d4;strokeColor=#82b366;fontStyle=1;align=left;" vertex="1" parent="1">
      <mxGeometry x="20" y="380" width="180" height="90" as="geometry"/>
    </mxCell>

    <!-- riwi_suppliers -->
    <mxCell id="4" value="riwi_suppliers&#xa;──────────&#xa;🔑 supplier_id PK&#xa;supplier_name UNIQUE&#xa;🔗 city_id FK" style="rounded=1;fillColor=#fff2cc;strokeColor=#d6b656;fontStyle=1;align=left;" vertex="1" parent="1">
      <mxGeometry x="260" y="100" width="180" height="100" as="geometry"/>
    </mxCell>

    <!-- riwi_warehouses -->
    <mxCell id="5" value="riwi_warehouses&#xa;──────────&#xa;🔑 warehouse_id PK&#xa;warehouse_name UNIQUE&#xa;🔗 city_id FK" style="rounded=1;fillColor=#fff2cc;strokeColor=#d6b656;fontStyle=1;align=left;" vertex="1" parent="1">
      <mxGeometry x="260" y="300" width="180" height="100" as="geometry"/>
    </mxCell>

    <!-- riwi_products -->
    <mxCell id="6" value="riwi_products&#xa;──────────&#xa;🔑 product_id PK&#xa;product_name UNIQUE&#xa;unit_price&#xa;🔗 category_id FK" style="rounded=1;fillColor=#d5e8d4;strokeColor=#82b366;fontStyle=1;align=left;" vertex="1" parent="1">
      <mxGeometry x="260" y="480" width="180" height="110" as="geometry"/>
    </mxCell>

    <!-- riwi_purchases -->
    <mxCell id="7" value="riwi_purchases&#xa;──────────&#xa;🔑 purchase_id PK&#xa;purchase_order UNIQUE&#xa;purchase_date&#xa;quantity&#xa;unit_price&#xa;🔗 supplier_id FK&#xa;🔗 product_id FK" style="rounded=1;fillColor=#ffe6cc;strokeColor=#d79b00;fontStyle=1;align=left;" vertex="1" parent="1">
      <mxGeometry x="500" y="200" width="180" height="160" as="geometry"/>
    </mxCell>

    <!-- riwi_inventory_movements -->
    <mxCell id="8" value="riwi_inventory_movements&#xa;──────────&#xa;🔑 movement_id PK&#xa;movement_date&#xa;movement_type IN/OUT&#xa;quantity&#xa;🔗 product_id FK&#xa;🔗 warehouse_id FK&#xa;🔗 purchase_id FK" style="rounded=1;fillColor=#f8cecc;strokeColor=#b85450;fontStyle=1;align=left;" vertex="1" parent="1">
      <mxGeometry x="500" y="420" width="200" height="160" as="geometry"/>
    </mxCell>

    <!-- Edges -->
    <mxCell edge="1" source="2" target="4" value="1:N" parent="1"><mxGeometry relative="1" as="geometry"/></mxCell>
    <mxCell edge="1" source="2" target="5" value="1:N" parent="1"><mxGeometry relative="1" as="geometry"/></mxCell>
    <mxCell edge="1" source="3" target="6" value="1:N" parent="1"><mxGeometry relative="1" as="geometry"/></mxCell>
    <mxCell edge="1" source="4" target="7" value="1:N" parent="1"><mxGeometry relative="1" as="geometry"/></mxCell>
    <mxCell edge="1" source="6" target="7" value="1:N" parent="1"><mxGeometry relative="1" as="geometry"/></mxCell>
    <mxCell edge="1" source="6" target="8" value="1:N" parent="1"><mxGeometry relative="1" as="geometry"/></mxCell>
    <mxCell edge="1" source="5" target="8" value="1:N" parent="1"><mxGeometry relative="1" as="geometry"/></mxCell>
    <mxCell edge="1" source="7" target="8" value="1:N (opt)" parent="1"><mxGeometry relative="1" as="geometry"/></mxCell>
  </root>
</mxGraphModel>
```
