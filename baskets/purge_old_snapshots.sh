#!/usr/bin/env bash

BASEDIR=$(dirname "$0")
ACTIVEBASKET=$(readlink -f $BASEDIR/baskets-enabled|grep -Po "[^/]*$")

echo "The active Basket is: \"$ACTIVEBASKET\""
echo "So we might delete the following"
ls $BASEDIR | grep -P "^basket_snapshots_\d{2}-\d{2}-\d{4}_\d{6}$"|grep -v $ACTIVEBASKET|while read i; do echo $i; done

echo -n "proceed? [y|N]"
read answer

case ${answer:0:1} in
  y|Y )
    echo DELETE
    ls $BASEDIR | grep -P "^basket_snapshots_\d{2}-\d{2}-\d{4}_\d{6}$"|grep -v $ACTIVEBASKET|while read i; do rm -rvf "$BASEDIR/$i"; done
  ;;
  * )
    echo "Deleted Nothing. Bye"
  ;;
esac
