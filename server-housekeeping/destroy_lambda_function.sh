#!/bin/sh
. env.sh

aws lambda delete-function --region $REGION \
    --function-name $LAMBDA_LIFECYCLE_FUN

aws logs delete-log-group --region $REGION \
    --log-group-name "/aws/lambda/$LAMBDA_LIFECYCLE_FUN"

exit 0
