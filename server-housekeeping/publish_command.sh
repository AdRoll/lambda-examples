#!/bin/sh -e
. env.sh

ACCOUNT=$(aws sns list-topics --region $REGION \
              --output text --query 'Topics[].TopicArn' \
                 | awk '{print $1}' \
                 | awk -F':' '{print $5}')

ARN="arn:aws:sns:$REGION:$ACCOUNT:$GLOBAL_TOPIC"

aws sns publish --region $REGION \
    --topic-arn $ARN \
    --message "$*"
