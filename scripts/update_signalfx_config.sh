#! /bin/bash
# Version 2.0
## It's not possible to deploy signalfx with the api and 
## ingest_url pointing at the Collector as install fails
## so we update them after the initial installation
### NEED TO TEST THIS AGAIN AS THIS MAY BE INCORRECT ###

sed -i -e 's+intervalSeconds.*+intervalSeconds: 1+g' /etc/signalfx/agent.yaml

mv /etc/signalfx/ingest_url /etc/signalfx/ingest_url_old
mv /etc/signalfx/api_url /etc/signalfx/api_url_old
mv /etc/signalfx/trace_endpoint_url /etc/signalfx/trace_endpoint_url_old

echo http://localhost:9943 > /etc/signalfx/ingest_url
echo http://localhost:6060 > /etc/signalfx/api_url
echo http://localhost:7276/v2/trace > /etc/signalfx/trace_endpoint_url
