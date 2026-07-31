# Incremental Data Processing with Delta Lake
### Superstore Customer Dimension — Load • Clean • Merge (SCD1 & SCD2) • Validate

##  Objective

Perform incremental data processing using **Delta Lake**:

1. Load a dataset into a Delta table
2. Perform basic cleaning (handle nulls, remove duplicates)
3. Create a second dataset simulating new/incremental data
4. Apply a MERGE operation to update existing records and insert new ones
5. Validate the results (row counts, duplicates)
6. Display the final dataset and a summary

The Sample Superstore dataset (9,994 order line-items / 793 unique customers) is used as
the source. From it we derive a customer dimension table — one row per customer with
profile attributes and rolled-up sales metrics — since this is the natural entity for
demonstrating inserts/updates via `MERGE`.

##  Engine Used

This project uses the official Python **[`deltalake`](https://pypi.org/project/deltalake/)**
library (the Rust-native Delta Lake engine, `delta-rs`) instead of `pyspark` + the
`delta-spark` JAR.

Both implement the exact same open **Delta Lake protocol** (transaction log, ACID `MERGE`,
schema enforcement, time travel/version history) — `deltalake` was chosen so the notebook runs
anywhere with just `pip install`, with no JVM, Spark cluster, or Maven artifact download
required. Every operation in the notebook (`write_deltalake`, `DeltaTable.merge()`,
`.history()`) is a direct, 1-to-1 equivalent of the same operation in PySpark's Delta API — the
underlying Delta table produced on disk is a standard Delta table readable by Spark, Databricks,
Trino, etc.

##  Project Structure

```
delta-lake-assignment/
│
├── data/
│   ├── Sample_-_Superstore.csv     # original raw source data (order line-items)
│   ├── customer_master.csv         # derived customer-dimension "master" snapshot
│   │                                 (seeded with a few nulls + duplicates for the cleaning step)
│   └── customer_incremental.csv    # simulated incremental batch (new + changed customers)
│
├── notebooks/
│   └── main.ipynb                  # the full, executed, end-to-end notebook
│
├── screenshots/
│   ├── data_loading/
│   ├── data_cleaning/
│   ├── scd1/
│   ├── scd2/
│   ├── validation/
│   └── final_output/
│
├── report/
│   └── assignment_summary.pdf      # optional short write-up
│
└── README.md
```

> Note: the `delta/` directory containing the actual Delta tables (transaction logs + Parquet
> files) is generated locally the first time the notebook runs and is not checked into GitHub
> (see `.gitignore` recommendation below) — it is fully reproducible from `data/` + the notebook.

##  How the Data Was Prepared

`customer_master.csv` / `customer_incremental.csv` are derived from the raw Superstore orders
as follows:

1. Aggregate the 9,994 order line-items into **793 unique customers**, computing profile
   attributes (segment, region, city, etc.) and rolled-up metrics (`total_sales`,
   `total_profit`, `total_orders`).
2. Split into a 650-customer master snapshot and a 143-customer "new" pool.
3. Seed the master snapshot with a handful of **null values** (city / postal code / segment)
   and a few exact duplicate rows, to give the cleaning step in the notebook something real
   to fix.
4. Build the incremental batch from: the 143 brand-new customers (→ inserts)  80 existing
   customers whose segment/city/sales/profit were changed (→ updates).

This mirrors a realistic pipeline: a master table that already has some data-quality issues,
plus a fresh batch containing a mix of new records and updates to existing ones.

## 📓 Notebook Walkthrough (`notebooks/main.ipynb`)

| Step | What happens |
|---|---|
| 1. Load into Delta | `customer_master.csv` → pandas → `write_deltalake()` → bronze Delta table `customer_raw` |
| 2. Clean | Null counts inspected; nulls filled (`Unknown` / median); exact duplicates and duplicate `customer_id`s removed; cleaned data written to a new Delta version (`customer_silver`) |
| 3. Incremental batch | `customer_incremental.csv` loaded; split logically into brand-new customers vs. existing customers with changed attributes |
| 4a. MERGE — SCD Type 1 | `DeltaTable.merge()` with `when_matched_update_all()` + `when_not_matched_insert_all()` — old attribute values are overwritten, only current state is kept |
| 4b. MERGE — SCD Type 2 | Two-step pattern: (i) `MERGE` to flip `is_current = false` / stamp `end_date` on rows that changed, (ii) `APPEND` a new `is_current = true` row for every new/changed customer — full history is preserved |
| **5. Validation** | Row-count arithmetic (`initial + inserts = final`), duplicate-`customer_id` checks, and inspection of the Delta transaction log (`DeltaTable.history()`) for every table |
| **6. Final output** | Final merged table displayed, `describe()` profile, and a summary table of every pipeline metric |

### Results from this run

| Metric | Value |
|---|---|
| Raw rows loaded (bronze) | 660 |
| Duplicate rows removed | 10 |
| Rows after cleaning (silver) | 650 |
| Incremental batch size | 223 |
| New customers inserted | 143 |
| Existing customers updated | 80 |
| Final row count — SCD1 (current state only) | 793 |
| Final row count — SCD2 (all versions incl. history) | 873 |
| Historical (superseded) rows kept by SCD2 | 80 |

Both the row-count and no-duplicate assertions in the notebook **passed**.

## ▶️ How to Run

```bash
pip install deltalake pandas pyarrow jupyter

cd notebooks
jupyter nbconvert --to notebook --execute --inplace main.ipynb
# or open main.ipynb in Jupyter/VS Code and Run All
```

The notebook is self-contained: it reads only from `../data/*.csv` and writes Delta tables to a
local `../delta/` folder (created automatically).

## Keypoint

- Delta Lake's `MERGE` applies inserts and updates from an incremental batch to the target
  table as a single atomic transaction — no manual delete theninsert scripting, no risk of
  partial writes.
- SCD Type 1 (overwrite) is right when only the *current* truth matters — e.g. a live
  customer profile.
- SCD Type 2 (preserve history) is right when auditability matters — e.g. "what segment
  was this customer in on a given date?", regulatory reporting, or point-in-time ML features.
- Every write created an independently queryable, versioned Delta table — anu step can be
  rolled back to or time-traveled through, which plain CSV/Parquet overwrites cannot offer.

## Screenshot


- `data_loading/` — reading the CSV and writing the first Delta table
- `data_cleaning/` — null/duplicate detection and the cleaning logic
- `scd1/` — the SCD Type 1 MERGE and before/after comparison
- `scd2/` — the two-step SCD Type 2 expire + append pattern
- `validation/` — row-count/duplicate assertions and Delta version history
- `final_output/` — the final merged table and pipeline summary
