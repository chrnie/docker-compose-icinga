#!/usr/bin/env bash

BASEDIR=$(dirname "$0")
DATE=$(date +"%d-%m-%Y_%H%M%S")

# Check if we are inside or outside container (should work with docker, podman, lxc ...)
# https://stackoverflow.com/questions/20010199/how-to-determine-if-a-process-runs-inside-lxc-docker/72136877#72136877

if [ -n "$(grep 'kthreadd' /proc/2/status 2>/dev/null)" ]; then
  echo "Not in container"
  tmpdir=/tmp/basket_snapshots_$DATE
  host_icingaweb=icinga-playground-icingaweb-1
  
  docker exec -u 0 -it $host_icingaweb bash -c "
  icingacli director basket list|while read i; do echo Snapshot \$i; icingacli director basket snapshot --name \"\$i\"; done
  mkdir $tmpdir
  icingacli director basket list|while read i; do echo Dump \$i; icingacli director basket dump --name \"\$i\" > \"$tmpdir/\$i.json\"; done
  "
  
  docker cp $host_icingaweb:$tmpdir $BASEDIR/
  
  printf "\nEnable this snapshot for next provisioning: \"$BASEDIR/enable_newest_snapshot.sh\"\n"
else
  echo "Do this outside the container!";
  exit 2
fi
  
