#!/usr/bin/env bash

BASEDIR=$(dirname "$0")

# Check if we are inside or outside container (should work with docker, podman, lxc ...)
# https://stackoverflow.com/questions/20010199/how-to-determine-if-a-process-runs-inside-lxc-docker/72136877#72136877

if [ -n "$(grep 'kthreadd' /proc/2/status 2>/dev/null)" ]; then
  echo "Not in container"
  # at first perform pending schema migrations
  docker exec -u 0 -it icinga-playground-icingaweb-1 bash -c 'icingacli director migration pending && icingacli director migration run && echo "director schema migration: done"'
  # restore all baskets
  docker exec -u 0 -it icinga-playground-icingaweb-1 bash -c 'ls /custom_data/baskets/baskets-enabled/*.json|while read json; do echo -n "$json: "; icingacli director basket restore < "$json"; done'
else
  echo "In container";
  # at first perform pending schema migrations
  icingacli director migration pending && icingacli director migration run && echo "director schema migration: done" 
  
  ls $BASEDIR/baskets-enabled/*.json|while read json; do echo -n "$json: "; icingacli director basket restore < "$json"; done
  
  icingacli director importsource run --id 1
  icingacli director syncrule run --id 1
  icingacli director config deploy
fi


