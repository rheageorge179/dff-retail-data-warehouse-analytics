# Architecture Notes

## Source Layer

The project uses four operational source families:

1. **Movement** — weekly sales movement by store, week, and UPC.
2. **UPC Master** — product metadata such as UPC, description, size, and category.
3. **Customer Count** — store-day traffic, department sales, and coupon activity.
4. **Demographics** — store-level income, household size, education, density, and competition attributes.

## Staging Layer

The staging layer mirrors the source file structure. The goal is to keep raw values traceable while adding load metadata such as:

- source filename
- load timestamp
- category/source indicator

## Data Warehouse Layer

The warehouse follows Kimball dimensional modeling.

### Conformed Dimensions

- `Dim_Date`
- `Dim_Store`
- `Dim_Product`
- `Dim_Promotion`
- `Dim_Price_Tier`
- `Dim_Store_Demo`

### Fact Tables

| Fact Table | Grain | Main Purpose |
|---|---|---|
| `Fact_Sales` | Store × Week × Product | Sales, margin, pricing, promotion analysis |
| `Fact_Store_Perf` | Store × Week | Traffic vs sales conversion |
| `Fact_Promotion_Impact` | Store × Week × Product promotion rows | Coupon/promotion lift and margin impact |
| `Fact_Demographics` | Store × Week | Sales and coupon behavior by demographics |

## Reporting Layer

The reporting layer maps directly to business questions:

- BQ1: Profitability by category, season, and promotion type
- BQ2: Price elasticity across categories and price tiers
- BQ3: Store foot traffic vs weekly sales
- BQ4: Manufacturer coupons vs store promotions
- BQ8: Demographic segmentation of sales and coupon usage
