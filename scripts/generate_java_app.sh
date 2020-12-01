#! /bin/bash
# Version 2.0

JAVA_APP_URL=$1
INVOKE_URL=$2

cat << EOF > /tmp/java_app.sh
#! /bin/bash
# Version 2.0
apt update 
git clone "$JAVA_APP_URL"
sed -i -e "s+REPLACEWITHRETAILORDER+$INVOKE_URL+g" /home/ubuntu/SplunkLambdaAPM/LocalLambdaCallers/JavaLambdaAPM/src/main/java/com/sfx/JavaLambda/JavaLambdaController.java
sed -i -e "s+REPLACEWITHRETAILORDER+$INVOKE_URL+g" /home/ubuntu/SplunkLambdaAPM/LocalLambdaCallers/JavaLambdaBase/src/main/java/com/sfx/JavaLambda/JavaLambdaController.java
apt install maven -y
EOF