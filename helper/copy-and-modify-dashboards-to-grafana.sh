#!/usr/bin/env bash

DASHBOARD_GIT_DIR=./icingaweb2-module-grafana/dashboards/influxdb
DASHBOARD_GRAFANA_DIR=./grafana_config/dashboards

[ ! -d $DASHBOARD_GIT_DIR ] && echo "$DASHBOARD_GIT_DIR not a directory" && exit 2
[ -d $DASHBOARD_GRAFANA_DIR ] && echo "$DASHBOARD_GRAFANA_DIR already exists" && exit 2

cp -r $DASHBOARD_GIT_DIR $DASHBOARD_GRAFANA_DIR && echo "SUCCESS: cp -r $DASHBOARD_GIT_DIR $DASHBOARD_GRAFANA_DIR"

for DIR in $DASHBOARD_GRAFANA_DIR $DASHBOARD_GRAFANA_DIR/itl; do
  # Change Datasources to "icinga2-influxDB", it's provided by config/grafana/icinga_datasources.yaml
  sed -i 's/\${DS_ICINGA2}/icinga2-influxDB/g' $DIR/*.json
  sed -i 's/\${DS_ICINGA2-INFLUXDB}/icinga2-influxDB/g' $DIR/*.json
  # Add a not so U ID to make configuration easy
  sed -i "2 { F; }" $DIR/*.json 
  sed -i '2 s/^.*\///; 2 s/^/  "uid": "/;2 s/.json$/",/' $DIR/*.json
done

echo "Datasource has been set to 'icinga2-influxDB'."
echo "UIDs have been added according to the filenames."

