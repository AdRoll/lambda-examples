#!/bin/sh
. env.sh

ACCOUNT=$(aws sns list-topics --region $REGION \
              --output text --query 'Topics[].TopicArn' \
                 | awk '{print $1}' \
                 | awk -F':' '{print $5}')

LIFECYCLE_TOPIC_ARN="arn:aws:sns:$REGION:$ACCOUNT:$LIFECYCLE_TOPIC"

aws sns delete-topic --region $REGION \
    --topic-arn "$LIFECYCLE_TOPIC_ARN" \
    && echo "deleted topic $LIFECYCLE_TOPIC_ARN"

GLOBAL_TOPIC_ARN="arn:aws:sns:$REGION:$ACCOUNT:$GLOBAL_TOPIC"

aws sns delete-topic --region $REGION \
    --topic-arn "$GLOBAL_TOPIC_ARN" \
    && echo "deleted topic $GLOBAL_TOPIC_ARN"

exit 0
