#!/bin/sh -e
. env.sh

TABLE_ARN=$(aws dynamodb describe-table --region $REGION \
                --output text --query 'Table.TableArn' \
                --table-name $TABLE_NAME || true)

if [ -z "$TABLE_ARN" ] || [ "None" = "$TABLE_ARN" ]; then
    TABLE_ARN=$(aws dynamodb create-table --region $REGION \
                    --table-name $TABLE_NAME \
                    --provisioned-throughput ReadCapacityUnits=1,WriteCapacityUnits=1 \
                    --key-schema AttributeName=InstanceID,KeyType=HASH \
                    --attribute-definitions AttributeName=InstanceID,AttributeType=S \
                    --output text --query 'TableDescription.TableArn')
fi

echo "dynamodb table: $TABLE_ARN"
