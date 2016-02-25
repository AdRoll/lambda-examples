#!/bin/sh
. env.sh

destroy_function () {
    FUN="$1"
    LOG_GROUP="/aws/lambda/$FUN"

    aws lambda delete-function --region $REGION \
        --function-name $FUN && \
        echo "destroyed $FUN"
    aws logs delete-log-group --region $REGION \
        --log-group-name "$LOG_GROUP" && \
        echo "destroyed $LOG_GROUP"
}

destroy_function $VALIDATOR_FUNCTION
destroy_function $EXECUTOR_FUNCTION

exit 0
