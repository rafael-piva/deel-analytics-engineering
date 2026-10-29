-- One-time Snowflake setup for the dbt project.
-- Run in a Snowsight worksheet as ACCOUNTADMIN (a trial account works).
-- Replace <PUBLIC_KEY> with the contents of snowflake_dbt_key.pub, without the
-- BEGIN/END lines and line breaks (see README for how to generate the key).

use role accountadmin;

create warehouse if not exists transforming
  warehouse_size = xsmall
  auto_suspend = 60
  auto_resume = true
  initially_suspended = true;

create database if not exists deel_ae;

create role if not exists transformer;
grant usage on warehouse transforming to role transformer;
grant usage, create schema on database deel_ae to role transformer;

create user if not exists dbt_user
  type = service
  default_role = transformer
  default_warehouse = transforming
  rsa_public_key = '<PUBLIC_KEY>';

grant role transformer to user dbt_user;
-- Lets you inspect dbt's output from your own login in Snowsight.
grant role transformer to role sysadmin;
