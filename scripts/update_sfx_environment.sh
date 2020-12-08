#! /bin/bash
# Version 2.0

ENVIRONMENT=$1
ENV_PREFIX=$2
# echo $ENVIRONMENT > /tmp/environment # just for debugging
# echo $ENV_PREFIX > /tmp/env_prefix # just for debugging

sed -i -e "s+    #defaultSpanTags:+    defaultSpanTags:+g" /etc/signalfx/agent.yaml
sed -i -e "s+     #environment: \"YOUR_ENVIRONMENT\"+     environment: \"$ENV_PREFIX\_$ENVIRONMENT\"+g" /etc/signalfx/agent.yaml 
