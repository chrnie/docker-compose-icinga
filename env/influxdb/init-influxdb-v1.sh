#!/bin/bash
set -e

ICINGA_BUCKET=$(influx bucket list |grep -P "\sicinga\s" | grep -Po "^\S*")

#echo "create extra buckets"
#influx bucket create -n icinga_ret1 -r 
#influx bucket create -n icinga_ret2 -r 168h

echo "create READ and WRITE token"
influx auth create --read-buckets -d "READ BUCKETS"
influx auth create --write-bucket $ICINGA_BUCKET -d "WRITE icinga"

echo "create compat interface for influxql dashboards"
influx v1 dbrp create --bucket-id $ICINGA_BUCKET --db ${INFLUXDB_V1_DATABASE} --rp icingaRP --default
influx v1 auth create --username icinga --password ${INFLUXDB_V1_PASSWORD} --read-bucket $ICINGA_BUCKET

echo "init OK"

