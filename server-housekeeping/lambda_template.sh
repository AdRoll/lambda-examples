#!/bin/sh -e
. env.sh

ACCOUNT=$(aws sns list-topics --region $REGION \
              --output text --query 'Topics[].TopicArn' \
                 | awk '{print $1}' \
                 | awk -F':' '{print $5}')

GLOBAL_TOPIC_ARN="arn:aws:sns:$REGION:$ACCOUNT:$GLOBAL_TOPIC"

cat lambda_function.py.src \
    | sed -e "s|%%PREFIX%%|$PREFIX|g" \
          -e "s|%%REGION%%|$REGION|g" \
          -e "s|%%TABLE_NAME%%|$TABLE_NAME|g" \
          -e "s|%%GLOBAL_TOPIC_ARN%%|$GLOBAL_TOPIC_ARN|g" > lambda_function.py

zip -j lambda-code.zip lambda_function.py
