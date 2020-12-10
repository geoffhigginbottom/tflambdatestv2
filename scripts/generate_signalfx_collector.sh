#! /bin/bash
# Version 2.0

ENVIRONMENT=$1

cat << EOF > /tmp/collector.yaml

# Configuration file that uses the Splunk exporters (SAPM, SignalFX) to push
# data to Splunk products.

receivers:
  jaeger:
    protocols:
      grpc:
      thrift_binary:
      thrift_compact:
      thrift_http:
  opencensus:
  otlp:
    protocols:
      grpc:
      http:
  # This section is used to collect the OpenTelemetry Collector metrics
  # Even if just a Splunk µAPM customer, these metrics are included
  prometheus:
    config:
      scrape_configs:
      - job_name: 'otel-collector'
        scrape_interval: 10s
        static_configs:
        - targets: ['0.0.0.0:8888']
          # labels:
          #   environment: $ENVIRONMENT
            # Environment set here to enable filtering in the Otel dashboards
        metric_relabel_configs:
          - source_labels: [ __name__ ]
            regex: '.*grpc_io.*'
            action: drop
  sapm:
  signalfx:
  zipkin:

processors:
  batch:
  # Optional: If you want to add an environment tag
  # If this option is enabled it must be added to the pipeline section below
  attributes/newenvironment:
    actions:
    - key: environment
      value: $ENVIRONMENT
      action: insert
  # Enabling the memory_limiter is strongly recommended for every pipeline.
  # Configuration is based on the amount of memory allocated to the collector.
  # The configuration below assumes 2GB of memory. In general, the ballast
  # should be set to 1/3 of the collector's memory, the limit should be 90% of
  # the collector's memory up to 2GB, and the spike should be 25% of the
  # collector's memory up to 2GB. The simplest way to specify the ballast size is
  # set the value of SPLUNK_BALLAST_SIZE_MIB env variable. This will overrides
  # the value of --mem-ballast-size-mib command line flag. If SPLUNK_BALLAST_SIZE_MIB
  # is not defined then --mem-ballast-size-mib command line flag must be manually specified.
  # For more information about memory limiter, see
  # https://github.com/open-telemetry/opentelemetry-collector/blob/master/processor/memorylimiter/README.md
  memory_limiter:
    ballast_size_mib: \${SPLUNK_BALLAST_SIZE_MIB}
    check_interval: 2s
    limit_percentage: \${SPLUNK_MEMORY_LIMIT_PERCENTAGE}
    spike_limit_percentage: \${SPLUNK_MEMORY_SPIKE_PERCENTAGE}

exporters:
  # Traces
  sapm:
    access_token: "\${SPLUNK_ACCESS_TOKEN}"
    endpoint: "https://ingest.\${SPLUNK_REALM}.signalfx.com/v2/trace"
  signalfx_correlation:
    access_token: "\${SPLUNK_ACCESS_TOKEN}"
    endpoint: "https://api.\${SPLUNK_REALM}.signalfx.com"
  # Metrics + Events
  signalfx:
    access_token: "\${SPLUNK_ACCESS_TOKEN}"
    realm: "\${SPLUNK_REALM}"
  #logging:
    #loglevel: debug

extensions:
  health_check:
  http_forwarder:
    egress:
      endpoint: "https://api.\${SPLUNK_REALM}.signalfx.com"
  zpages:
    #endpoint: 0.0.0.0:55679

service:
  pipelines:
    traces:
      receivers: [jaeger, opencensus, otlp, sapm, zipkin]
      processors: [memory_limiter, batch]
      exporters: [sapm, signalfx_correlation]
    metrics:
      receivers: [opencensus, otlp, signalfx, prometheus]
      processors: [memory_limiter, batch]
      exporters: [signalfx]
    logs:
      receivers: [signalfx]
      processors: [memory_limiter, batch]
      exporters: [signalfx]

  extensions: [health_check, http_forwarder, zpages]

EOF