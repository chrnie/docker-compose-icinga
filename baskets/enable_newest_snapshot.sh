#!/usr/bin/env bash

BASEDIR=$(dirname "$0")

NEWBASKET=$(ls $BASEDIR | grep -P "^basket_snapshots_\d{2}-\d{2}-\d{4}_\d{6}$"|tail -n1)

echo "Enable new basket dir \"$NEWBASKET\""
ln -snvf "./$NEWBASKET" "$BASEDIR/baskets-enabled"
