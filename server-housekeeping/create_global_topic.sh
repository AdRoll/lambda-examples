#!/bin/sh -e
. env.sh

# note: re-running this returns the same topic:
TOPIC_ARN=$(aws sns create-topic --region $REGION \
                --name $GLOBAL_TOPIC \
                --output text --query 'TopicArn')

echo "global topic: $TOPIC_ARN"
