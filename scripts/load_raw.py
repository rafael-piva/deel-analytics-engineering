"""Loads the Globepay CSVs into DEEL_AE.RAW as text, replacing the tables on each run.

    set -a; source .env; set +a
    python scripts/load_raw.py
"""

import csv
import os
from pathlib import Path

import snowflake.connector

DATA_DIR = Path(__file__).resolve().parent.parent / "data"
DATABASE = os.environ.get("SNOWFLAKE_DATABASE", "DEEL_AE")
RAW_SCHEMA = os.environ.get("SNOWFLAKE_RAW_SCHEMA", "RAW")

TABLES = {
    "GLOBEPAY_ACCEPTANCE_REPORT": "globepay_acceptance_report.csv",
    "GLOBEPAY_CHARGEBACK_REPORT": "globepay_chargeback_report.csv",
}


def connect():
    params = dict(
        account=os.environ["SNOWFLAKE_ACCOUNT"],
        user=os.environ["SNOWFLAKE_USER"],
        role=os.environ.get("SNOWFLAKE_ROLE", "TRANSFORMER"),
        warehouse=os.environ.get("SNOWFLAKE_WAREHOUSE", "TRANSFORMING"),
    )
    params["private_key_file"] = os.path.expanduser(os.environ["SNOWFLAKE_PRIVATE_KEY_PATH"])
    if os.environ.get("SNOWFLAKE_PRIVATE_KEY_PASSPHRASE"):
        params["private_key_file_pwd"] = os.environ["SNOWFLAKE_PRIVATE_KEY_PASSPHRASE"]
    return snowflake.connector.connect(**params)


def read_header(path):
    with path.open(newline="") as f:
        return [col.strip().upper() for col in next(csv.reader(f))]


def load_table(cur, table, path):
    columns = read_header(path)
    column_defs = ",\n  ".join(f"{col} varchar" for col in columns)
    cur.execute(f"""
        create or replace table {table} (
          {column_defs},
          _source_file varchar,
          _loaded_at timestamp_ltz
        )
    """)

    cur.execute(f"put 'file://{path}' @%{table} overwrite = true auto_compress = true")
    positional = ", ".join(f"t.${i}" for i in range(1, len(columns) + 1))
    cur.execute(f"""
        copy into {table}
        from (
          select {positional}, metadata$filename, current_timestamp()
          from @%{table} t
        )
        file_format = (
          type = csv
          skip_header = 1
          field_optionally_enclosed_by = '"'
          empty_field_as_null = true
        )
        on_error = abort_statement
        purge = true
    """)
    rows_loaded = sum(row[3] for row in cur.fetchall())
    print(f"{RAW_SCHEMA}.{table}: {rows_loaded} rows loaded from {path.name}")


def main():
    with connect() as conn, conn.cursor() as cur:
        cur.execute(f"create database if not exists {DATABASE}")
        cur.execute(f"create schema if not exists {DATABASE}.{RAW_SCHEMA}")
        cur.execute(f"use schema {DATABASE}.{RAW_SCHEMA}")
        for table, filename in TABLES.items():
            load_table(cur, table, DATA_DIR / filename)


if __name__ == "__main__":
    main()
