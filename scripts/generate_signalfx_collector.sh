#! /bin/bash
# Version 2.0

ZPAGES_ENDPOINT=$1
ENVIRONMENT=$2
TOKEN=$3
SFX_ENDPOINT=$4
REALM=$5

cat << EOF > /tmp/collector.yaml

extensions:
  health_check:
  http_forwarder:
    egress:
    #   endpoint: "https://api.${SFX_REALM}.signalfx.com"
      endpoint: "$ZPAGES_ENDPOINT"
  zpages:
receivers:
  sapm:
  signalfx:
  # This section is used to collect the OpenTelemetry Collector metrics
  # Even if just a SignalFx µAPM customer, these metrics are included
  prometheus:
    config:
      scrape_configs:
        - job_name: 'otel-collector'
          scrape_interval: 10s
          static_configs:
            - targets: ['localhost:8888']
              # If you want to use the environment filter
              # In the SignalFx dashboard
              #labels:
                #environment: demo
              labels:
                environment: $ENVIRONMENT
          metric_relabel_configs:
            - source_labels: [ __name__ ]
              regex: '.*grpc_io.*'
              action: drop
  # Enable Zipkin to support Istio Mixer Adapter
  # https://github.com/signalfx/signalfx-istio-adapter
  zipkin:
processors:
  batch:
  # Optional: If you have a different environment tag name
  # If this option is enabled it must be added to the pipeline section below
  #attributes/copyfromexistingkey:
    #actions:
    #- key: environment
      #from_attribute: YOUR_EXISTING_TAG_NAMEE
      #action: upsert
  # Optional: If you want to add an environment tag
  # If this option is enabled it must be added to the pipeline section below
  #attributes/newenvironment:
    #actions:
    #- key: environment
      #value: "YOUR_ENVIRONMENT_NAME"
      #action: insert
  # Enabling the memory_limiter is strongly recommended for every pipeline.
  # Configuration is based on the amount of memory allocated to the collector.
  # The configuration below assumes 2GB of memory. In general, the ballast
  # should be set to 1/3 of the collector's memory, the limit should be 90% of
  # the collector's memory up to 2GB, and the spike should be 25% of the
  # collector's memory up to 2GB. In addition, the "--mem-ballast-size-mib" CLI
  # flag must be set to the same value as the "ballast_size_mib". For more
  # information, see
  # https://github.com/open-telemetry/opentelemetry-collector/blob/master/processor/memorylimiter/README.md
  memory_limiter:
    ballast_size_mib: 683
    check_interval: 2s
    limit_mib: 1800
    spike_limit_mib: 500
exporters:
  # Traces
  sapm:
    # access_token: "${SFX_TOKEN}"
    access_token: "$TOKEN"
    # endpoint: "https://ingest.$REALM.signalfx.com/v2/trace"
    endpoint: "$SFX_ENDPOINT"
  # Metrics + Events
  signalfx:
    # access_token: "${SFX_TOKEN}"
    access_token: "$TOKEN"
    # realm: "${SFX_REALM}"
    realm: "$REALM"
service:
  pipelines:
    traces:
      receivers: [sapm, zipkin]
      processors: [memory_limiter, batch]
      exporters: [sapm]
    metrics:
      receivers: [signalfx, prometheus]
      processors: [memory_limiter, batch]
      exporters: [signalfx]
    logs:
      receivers: [signalfx]
      processors: [memory_limiter, batch]
      exporters: [signalfx]
  extensions: [health_check, http_forwarder, zpages]

EOF