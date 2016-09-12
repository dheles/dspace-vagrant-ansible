#!/usr/bin/env bash

DB_USER="dspace"
DB_NAME="dspace"
IDS="667"

bash -c "psql -U $DB_USER $DB_NAME -v ids=$IDS < ./test_select.sql"
