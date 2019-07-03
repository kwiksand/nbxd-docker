#!/bin/bash

set -e
NETBOX_HOME=/home/netbox
NETBOX_DATA=$NETBOX_HOME/.netbox
CONFIG_FILE=nbx.conf

if [ -z "$1" ] || [ "$1" == "nbxd" ] || [ "$(echo "$0" | cut -c1)" == "-" ]; then
  cmd=nbxd
  shift

  if [ ! -d $NETBOX_DATA ]; then
    echo "$0: DATA DIR ($NETBOX_DATA) not found, please create and add config.  exiting...."
    exit 1
  fi

  if [ ! -f $NETBOX_DATA/$CONFIG_FILE ]; then
    if [ -f $NETBOX_HOME/$CONFIG_FILE ];
      echo "$0: nbxd config ($NETBOX_DATA/$CONFIG_FILE) not found, copying templated sample...."
      #found example
      cp $NETBOX_HOME/$CONFIG_FILE $NETBOX_DATA/$CONFIG_FILE
    else 
      echo "$0: nbxd config ($NETBOX_DATA/$CONFIG_FILE) not found, please create.  exiting...."
      exit 1
    fi
  fi

  chmod 700 "$NETBOX_DATA"
  chown -R netbox "$NETBOX_DATA"

  if [ -z "$1" ] || [ "$(echo "$1" | cut -c1)" == "-" ]; then
    echo "$0: assuming arguments for nbxd"

    set -- $cmd "$@" -datadir="$NETBOX_DATA"
  else
    set -- $cmd -datadir="$NETBOX_DATA"
  fi

  exec gosu netbox "$@"
else
  echo "This entrypoint will only execute nbxd, nbx-cli and nbx-tx"
fi
