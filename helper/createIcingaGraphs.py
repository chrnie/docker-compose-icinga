#!/bin/python3

import requests

# dashboard list
searchlist = ['disk', 'hostalive', 'hostalive4', 'hostalive6', 'http', 'ido', 'load', 'nscp-local-cpu', 'nscp-local-disk-free', 'nscp-local-memory', 'nscp-local-pagefile', 'ntp_time', 'ping', 'ping4', 'ping6', 'ssh', 'swap']

#  icingaweb.modules.grafana.graphs.<template_name>.key: "value"
for item in searchlist:
  print('  icingaweb.modules.grafana.graphs.' + item + '.dashboard: "' + item + '"')
  print('  icingaweb.modules.grafana.graphs.' + item + '.panelId: "1"')
  print('  icingaweb.modules.grafana.graphs.' + item + '.orgId: "1"')
  print('  icingaweb.modules.grafana.graphs.' + item + '.repeatable: "no"')
  print('  icingaweb.modules.grafana.graphs.' + item + '.dashboarduid: "' + item + '"')

