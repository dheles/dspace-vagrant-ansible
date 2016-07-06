#!/usr/bin/env bash

# TODO: if PII, run only on an authorized machine
# optionally ssh tunnel to machine with postgres access to target db
# create dir and backup db
# see: db_restore.sh (run on dev db server)
# restore db
# optionally anonymize it (TODO: if needed?)
# see: db_upgrade.sh (run on dev app server)
# upgrade db
# connect and test
