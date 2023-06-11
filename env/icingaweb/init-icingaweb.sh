#!/usr/bin/env bash

set -e
set -o pipefail

echo "INIT GRAFANA AND RESTORE BASKETS"
sleep 2

icingaweb_module_grafana_config_ini=/data/etc/icingaweb2/modules/grafana/config.ini

if [ -f $icingaweb_module_grafana_config_ini ] && ! grep -q '^apitoken' $icingaweb_module_grafana_config_ini; then
  echo -n "SET GRAFANA API TOKEN: "
  TOKEN=$(/config/createGrafanaServiceAccount.php 'icinga_read22' | grep '^Token:'|sed 's/Token:\s*//') || echo "CANNOT CREATE TOKEN"
  echo $TOKEN
  echo Write Token to $icingaweb_module_grafana_config_ini
  echo "apitoken = \"$TOKEN\"" >> $icingaweb_module_grafana_config_ini && echo "DONE"
fi

exec apache2 -DFOREGROUND
