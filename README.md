# deel-ae
repo to include the files for the senior analytics engineering home case for deel

The challenge brief and source files are in [docs/](docs/hometaskassignmentanalyticsengineer).

- [Part 1: ingestion and modeling](docs/part_1_data_modeling.md): data exploration, model architecture, lineage,
  and tips on macros, validation and documentation.
- [Part 2: production model and answers](docs/part_2_analysis.md): `fct_transactions` and the queries answering
  the analyst's three questions.

## Setup

### 1. Python + dbt

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

### 2. Snowflake

Generate a key pair:

```bash
openssl genrsa 2048 | openssl pkcs8 -topk8 -inform PEM -out ~/.ssh/snowflake_dbt_key.p8 -nocrypt
openssl rsa -in ~/.ssh/snowflake_dbt_key.p8 -pubout -out ~/.ssh/snowflake_dbt_key.pub
```

Attach the public key to a Snowflake user. Either your own user, in a Snowsight worksheet:

```sql
alter user <your_user> set rsa_public_key = '<contents of snowflake_dbt_key.pub, one line, no BEGIN/END>';
```

or a dedicated service user: run [scripts/snowflake_setup.sql](scripts/snowflake_setup.sql) as ACCOUNTADMIN with the
key pasted in place of `<PUBLIC_KEY>`. It creates the `TRANSFORMING` warehouse, `DEEL_AE` database,
`TRANSFORMER` role and `DBT_USER`.

### 3. Connect dbt

```bash
cp .env.example .env   # then fill in account, user, role and warehouse
set -a; source .env; set +a
dbt deps
dbt debug
```

`profiles.yml` lives in the repo and reads every credential from environment variables.

### 4. Load the raw data

The two Globepay CSVs are in `data/`. [scripts/load_raw.py](scripts/load_raw.py) stands in for an EL tool: it
loads them as-is (all text, plus `_source_file` and `_loaded_at`) into `DEEL_AE.RAW`, fully reloading on each run.

```bash
python scripts/load_raw.py
```

dbt reads them as sources, declared in [models/staging/globepay/_globepay__sources.yml](models/staging/globepay/_globepay__sources.yml):
`{{ source('globepay', 'globepay_acceptance_report') }}` and `{{ source('globepay', 'globepay_chargeback_report') }}`.

### 5. Build

```bash
dbt build                  # dev: DBT_DEV_STAGING, DBT_DEV_INTERMEDIATE, DBT_DEV_MARTS
dbt build --target prod    # prod: STAGING, INTERMEDIATE, MARTS
```

## Project layout

```
data/                  raw Globepay CSV reports
scripts/               Snowflake setup and raw data loader
models/staging/        source definitions and 1:1 cleaned views over them
models/intermediate/   joins and business logic
models/marts/          tables for the analyst
analyses/              versioned ad-hoc SQL (data exploration, analyst questions)
macros/, tests/        reusable SQL and custom data tests
```
