#! /bin/bash
# Version 2.0
TOKEN=$1
REALM=$2
VERSION=$3

if [ -z "$1" ] ; then
  printf "Token not set, exiting ...\n"
  exit 1
else
  printf "Token Variable Detected ...\n"
fi

if [ -z "$2" ] ; then
  printf "Realm not set, exiting ...\n"
  exit 1
else
  printf "Realm Variable Detected ...\n"
fi

curl -sSL https://dl.signalfx.com/signalfx-agent.sh > /tmp/signalfx-agent.sh

if [ -z "$3" ] ; then
  printf "Version not specified, installing Latest version ...\n"
  sudo sh /tmp/signalfx-agent.sh --ingest-url https://ingest.$REALM.signalfx.com --api-url https://api.$REALM.signalfx.com --trace-url https://ingest.$REALM.signalfx.com/v2/trace $TOKEN
  exit 1
else
  printf "Version Variable Detected - Installing SignalFX Version $VERSION ..\n"
  sudo sh /tmp/signalfx-agent.sh --ingest-url https://ingest.$REALM.signalfx.com --api-url https://api.$REALM.signalfx.com --trace-url https://ingest.$REALM.signalfx.com/v2/trace $TOKEN --package-version $VERSION
fi
