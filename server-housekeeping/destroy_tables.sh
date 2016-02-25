#!/bin/sh
. env.sh

TABLE_ARN=$(aws dynamodb describe-table --region $REGION \
                --output text --query 'Table.TableArn' \
                --table-name $TABLE_NAME || true)

if [ ! -z "$TABLE_ARN" ] && [ "None" != "$TABLE_ARN" ]; then
    aws dynamodb delete-table --region $REGION \
        --table-name $TABLE_NAME && \
        echo "deleted table $TABLE_NAME"
fi
