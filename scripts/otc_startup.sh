#! /bin/bash
# Version 2.0

COLLECTOR_YAML_PATH=$1
NAME=$2
IMAGE=$3

docker stop otelcontribcol
docker rm otelcontribcol
docker run -d --restart unless-stopped -p 7276:7276 -p 8888:8888 -p 9943:9943 -p 55679:55679 -p 55680:55680 -p 9411:9411 -v "$COLLECTOR_YAML_PATH":/etc/collector.yaml:ro --name $NAME $IMAGE --config /etc/collector.yaml --mem-ballast-size-mib=683