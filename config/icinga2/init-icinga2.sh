#!/usr/bin/env bash

set -e
set -o pipefail

# copy icingaweb-api-user
if [ ! -f /data/etc/icinga2/conf.d/icingaweb-api-user.conf ]; then
  sed "s/\$ICINGAWEB_ICINGA2_API_USER_PASSWORD/${ICINGAWEB_ICINGA2_API_USER_PASSWORD:-icingaweb}/" /config/icingaweb-api-user.conf >/data/etc/icinga2/conf.d/icingaweb-api-user.conf
fi

# exclude conf.d, include custom_data
sed -i 's#^include_recursive "conf.d"#//include_recursive "conf.d"\ninclude "conf.d/icingaweb-api-user.conf"\ninclude_recursive "/custom_data/custom.conf.d"#' /data/etc/icinga2/icinga2.conf

# copy icingadb.conf
if [ ! -f /data/etc/icinga2/features-enabled/icingadb.conf ]; then
  mkdir -p /data/etc/icinga2/features-enabled
  cat /config/icingadb.conf >/data/etc/icinga2/features-enabled/icingadb.conf
fi

if [ "${ICINGA2_FEATURE_INFLUXDB2}" == "1" ] ; then
	echo "=> Enabling Icinga2 influxdb2 writer"

	icinga2 feature enable influxdb2

	cat >/etc/icinga2/features-available/influxdb2.conf <<-END
        /**
         * The Influxdb2Writer type writes check result metrics and
         * performance data to an InfluxDB v2 HTTP API
         */
        object Influxdb2Writer "influxdb2" {
	  host = "$ICINGA2_FEATURE_INFLUXDB2_HOST"
	  port = "$ICINGA2_FEATURE_INFLUXDB2_PORT"
          organization = "$ICINGA2_FEATURE_INFLUXDB2_ORG"
          bucket = "$ICINGA2_FEATURE_INFLUXDB2_BUCKET"
          auth_token = "$ICINGA2_FEATURE_INFLUXDB2_TOKEN"
          flush_threshold = 1024
          flush_interval = 10s
          host_template = {
            measurement = "\$host.check_command$"
            tags = {
              hostname = "\$host.name$"
            }
          }
          service_template = {
            measurement = "\$service.check_command$"
            tags = {
              hostname = "\$host.name$"
              service = "\$service.name$"
            }
          }
	  enable_send_thresholds = $ICINGA2_FEATURE_INFLUXDB2_SEND_THRESHOLDS
	  enable_send_metadata = $ICINGA2_FEATURE_INFLUXDB2_SEND_METADATA
        }
	END
else
	# Actively disable influxdb2, to not hit any weird bugs
	icinga2 feature disable influxdb2 || true
fi

# set a password for mysql Monitoring
grep -q MYSQL_MONITORING_PASSWORD /data/etc/icinga2/constants.conf || sed -i "\$aconst MYSQL_MONITORING_PASSWORD = \"${ICINGA_MYSQL_MONITORING_PASSWORD:-icingamon}\"" /data/etc/icinga2/constants.conf

