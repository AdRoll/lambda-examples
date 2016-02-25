#!/bin/sh -e
. env.sh

create_log_group () {
    FUN="$1"
    LOG_GROUP="/aws/lambda/$FUN"

    EXISTS=$(aws logs describe-log-groups --region $REGION \
                 --log-group-name-prefix "$LOG_GROUP" \
                 --output text --query 'logGroups[0].arn' || true)

    if [ -z "$EXISTS" ] || [ "None" = "$EXISTS" ]; then
        aws logs create-log-group --region $REGION \
            --log-group-name "$LOG_GROUP"
        echo "created log group $LOG_GROUP"
    fi
}

create_log_group $VALIDATOR_FUNCTION
create_log_group $EXECUTOR_FUNCTION


create_function () {
    FUN="$1"
    ROLE="$2"
    WHICH="$3"
    BUNDLE="lambda-code-${WHICH}.zip"
    MODULE="lambda_${WHICH}"

    LAMBDA_ARN=$(aws lambda get-function --region $REGION \
                     --function-name $FUN \
                     --output text --query 'Configuration.FunctionArn' || true)

    if [ -z "$LAMBDA_ARN" ] || [ "None" = "$LAMBDA_ARN" ]; then
        zip -j "$BUNDLE" "${MODULE}.py"

        ROLE_ARN=$(aws iam get-role --region $REGION \
                       --role-name $ROLE \
                       --output text --query 'Role.Arn')

        LAMBDA_ARN=$(aws lambda create-function --region $REGION \
                         --runtime python2.7 \
                         --role "$ROLE_ARN"  \
                         --timeout 10        \
                         --memory-size 128   \
                         --handler ${MODULE}.lambda_handler \
                         --zip-file fileb://lambda-code-${WHICH}.zip \
                         --function-name $FUN \
                         --output text \
                         --query 'FunctionArn')
        echo "created function $LAMBDA_ARN"
    fi
}

create_function $VALIDATOR_FUNCTION $VALIDATOR_ROLE validator
create_function $EXECUTOR_FUNCTION $EXECUTOR_ROLE executor
