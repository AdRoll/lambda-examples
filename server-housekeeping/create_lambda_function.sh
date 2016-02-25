#!/bin/sh -e
. env.sh

LOG_GROUP="/aws/lambda/$LAMBDA_LIFECYCLE_FUN"

EXISTS=$(aws logs describe-log-groups --region $REGION \
             --log-group-name-prefix "$LOG_GROUP" \
             --output text --query 'logGroups[0].arn' || true)

if [ -z "$EXISTS" ] || [ "None" = "$EXISTS" ]; then
    aws logs create-log-group --region $REGION \
        --log-group-name "$LOG_GROUP"
    echo "created log group $LOG_GROUP"
fi

$(dirname $0)/lambda_template.sh

ROLE_ARN=$(aws iam get-role --region $REGION      \
               --role-name $LAMBDA_LIFECYCLE_ROLE \
               --output text --query 'Role.Arn')

LAMBDA_ARN=$(aws lambda get-function --region $REGION \
                 --function-name $LAMBDA_LIFECYCLE_FUN \
                 --output text --query 'Configuration.FunctionArn' || true)

if [ -z "$LAMBDA_ARN" ] || [ "None" = "$LAMBDA_ARN" ]; then
    LAMBDA_ARN=$(aws lambda create-function --region $REGION \
                     --runtime python2.7 \
                     --role "$ROLE_ARN"  \
                     --timeout 10        \
                     --memory-size 128   \
                     --handler lambda_function.lambda_handler \
                     --zip-file fileb://lambda-code.zip  \
                     --function-name $LAMBDA_LIFECYCLE_FUN \
                     --output text \
                     --query 'FunctionArn')
fi

echo "lambda function: $LAMBDA_ARN ($LAMBDA_LIFECYCLE_FUN)"

ACCOUNT=$(aws sns list-topics --region $REGION \
              --output text --query 'Topics[].TopicArn' \
                 | awk '{print $1}' \
                 | awk -F':' '{print $5}')

TOPIC_ARN="arn:aws:sns:$REGION:$ACCOUNT:$LIFECYCLE_TOPIC"

aws sns subscribe --region $REGION \
    --protocol lambda \
    --topic-arn $TOPIC_ARN \
    --notification-endpoint $LAMBDA_ARN

echo "subscribed $TOPIC_ARN -> $LAMBDA_ARN"


EXISTS=$(aws lambda get-policy --region $REGION \
             --function-name $LAMBDA_LIFECYCLE_FUN \
             --output text --query 'Policy' \
                | jq '.Statement[] | select(.Sid=="invoke")')

if [ -z "$EXISTS" ]; then
    aws lambda add-permission --region $REGION \
        --function-name $LAMBDA_ARN \
        --statement-id "invoke" \
        --principal "sns.amazonaws.com" \
        --action "lambda:InvokeFunction" \
        --source-arn $TOPIC_ARN
    echo "added invokeFunction permission to $TOPIC_ARN"
else
    echo "invokeFunction permission already present, not adding"
fi

echo "done creating lambda function"
