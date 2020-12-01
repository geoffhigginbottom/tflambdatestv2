#! /bin/bash
# Version 2.0

APP_VERSION=$1

cat << EOF > /tmp/run_splunk_lambda_apm.sh
#! /bin/bash
# Version 2.0

cd /home/ubuntu/SplunkLambdaAPM/LocalLambdaCallers/$APP_VERSION
mvn spring-boot:run
EOF