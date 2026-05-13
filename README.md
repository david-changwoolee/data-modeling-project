# Data Modeling Project

A **Docker**-based workspace for pulling **Kaggle** datasets into **DuckDB** (raw `lake` tables) and building **dbt** models (staging, dimensions, facts). The layout is meant to **scale to more Kaggle sources over time**—not tied to any single domain. Today’s repos include example projects; new datasets follow the same pattern.

### Authoring note

**This `README.md` was produced with the help of an AI coding agent** (drafting, structuring, and editing the documentation). **The application code in this repository**—including SQL, Python, Docker, and dbt project files—**was written directly by the project author**, not generated wholesale by that agent.

---

## What this project does

1. **Ingest**: Read dataset entries from `data/kaggle-urls` and download with `kagglehub`.
2. **Load**: For each dataset, create a DuckDB file under `data/duckdb/` and load CSV into a **`lake`** table via `read_csv`.
3. **Transform**: One **dbt project per dataset (or domain)**—typically `stage` → `dim_*` → `fact` (names may vary by use case).
4. **Test**: Declare source (and model) tests in YAML—e.g. `not_null`, `unique` on raw columns in `sources.yml`.

**Current examples** (illustrative only; more can be added the same way):

| dbt project        | Example Kaggle theme   | Models (illustrative) |
|--------------------|------------------------|------------------------|
| `used_car_sales`   | US used car listings   | `stage`, `dim_zipcode`, `dim_vehicles`, `fact` |
| `video_game_sales` | Video game sales       | `stage`, `dim_games`, `fact` |

---

## Tech stack

| Layer | Technology |
|-------|------------|
| Container | Docker (Ubuntu-based image) |
| Language | Python 3.12 |
| Warehouse / engine | DuckDB |
| Transform & tests | dbt (dbt-duckdb) |
| Ingestion | kagglehub; optional Polars / PyArrow |

---

## Repository layout (general pattern)

The repo is organized so **each new Kaggle-backed domain** gets the same building blocks: a registry line, raw files on disk, one DuckDB file, and one dbt project.

```
data-modeling-project/
├── Dockerfile                 # Runtime: Python, DuckDB, dbt, etc.
├── data/
│   └── kaggle-urls            # One row per dataset: slug,Kaggle_dataset_URL
├── dbt/
│   ├── profiles.yml           # One output per dbt project → DuckDB path
│   └── <your_dbt_project>/    # One folder per domain (SQL + YAML)
│       ├── sources.yml
│       ├── stage.sql
│       ├── dim_*.sql          # optional
│       └── fact.sql           # optional
└── pyscripts/
    ├── handling_data.py       # Download + create lake tables
    ├── create_lake_from_kaggle.py
    └── dbt/                   # Optional ad-hoc DuckDB query scripts
```

**Naming convention (recommended)**  
Use a **stable slug** for each dataset (e.g. `used_car_sales`). That slug should align with:

- A row in `data/kaggle-urls` (first column before the comma).
- The download folder under `data/kaggle/<slug>/` (or equivalent layout your scripts expect).
- The DuckDB filename, e.g. `data/duckdb/<slug>.db`.
- The dbt project directory name `dbt/<slug>/` and a matching entry in `profiles.yml`.

Inside the container, paths are often mirrored under `/root/data`, `/root/dbt`, `/root/pyscripts`.

---

## Adding another Kaggle dataset (checklist)

1. **Register** the dataset in `data/kaggle-urls` (`slug,https://www.kaggle.com/datasets/...`).
2. **Extend ingestion** if needed (nested CSVs, multiple files, non-CSV exports)—adjust `handling_data.py` or loaders accordingly.
3. **Create a dbt project** for that slug (`dbt init` or copy an existing project folder) and add models + `sources.yml` for the real `lake` column names.
4. **Register a profile** in `dbt/profiles.yml` pointing to `/root/data/duckdb/<slug>.db` (or your chosen path).
5. **Wire the Docker image** so the new `dbt/<slug>/` models are `COPY`’d into the image (or mount the repo for local iteration).
6. **Run** `dbt run` / `dbt test` from `/root/dbt/<slug>` (or equivalent).

Keeping slug ↔ URL ↔ DB file ↔ dbt project ↔ profile **in sync** avoids the most common “works on one dataset only” issues.

---

## Prerequisites

- Docker
- Kaggle API credentials for downloads: create `kaggle.json` from [Kaggle → Account → API](https://www.kaggle.com/docs/api) and mount or copy it into the container where `kagglehub` expects it.

---

## Quick run flow

1. **Build** the image from the repo root:

   ```bash
   docker build -t data-modeling .
   ```

2. **Run the container**, then inside the shell:

   - Run `pyscripts/create_lake_from_kaggle.py` (or your entrypoint) to populate DuckDB `lake` tables from Kaggle.
   - For each dbt project under `dbt/<slug>/`, run `dbt run` and `dbt test`.

DuckDB files are created per profile, e.g. `/root/data/duckdb/<slug>.db`.

---

## Common dbt commands

Example when the project lives at `/root/dbt/used_car_sales`:

```bash
dbt debug
dbt run
dbt test
dbt docs generate && dbt docs serve   # optional documentation
```

---

## Roadmap / improvements

Prioritize to taste.

1. **Reproducibility**: Pin base image tags and Python packages (`requirements.txt`, `uv.lock`, etc.).
2. **Developer experience**: `docker compose` for volumes (repo, `kaggle.json`, `data/duckdb`) and env vars.
3. **Profile hygiene**: Remove or implement dormant profiles (e.g. entries in `profiles.yml` without matching `dbt/` projects or `kaggle-urls` lines).
4. **dbt project defaults**: Centralize materializations in `dbt_project.yml` (e.g. staging as views, marts as tables).
5. **Richer tests**: `schema.yml` tests (`relationships`, `accepted_values`), custom tests, staging-level checks for messy fields (e.g. zip codes).
6. **Keys & joins**: Prefer surrogate keys (`dbt_utils.generate_surrogate_key`) over long natural-key joins where it helps.
7. **Loader robustness**: Multiple CSVs, nested paths, and refresh strategy instead of only `CREATE TABLE IF NOT EXISTS ... AS`.
8. **CI**: `dbt build` on pull requests with `--select state:modified+` when state artifacts are available.

---

## Conventions this README encodes

- One-line **purpose** and **end-to-end flow** (Kaggle → lake → dbt).
- **Extensible layout** and a **repeatable checklist** for new datasets.
- **Directory map** and **how slugs line up** across files.
- **Prerequisites** (Docker, Kaggle API).
- **How to run** and **sample dbt commands**.
- **Roadmap** and **operational gotchas** (profiles vs. Docker COPY, path alignment).

---

## Data & licensing

- Kaggle datasets are subject to **each dataset’s license** on Kaggle. Check terms before redistribution or commercial use.
- Prefer **not** committing large raw CSVs or DuckDB binaries; add `data/kaggle`, `data/duckdb`, etc. to `.gitignore` as appropriate.

---

## License

The **code and documentation in this repository** (excluding third-party Kaggle dataset content and their separate terms) are licensed under the **Apache License, Version 2.0**. See the [`LICENSE`](LICENSE) file for the full text.

SPDX-License-Identifier: Apache-2.0
