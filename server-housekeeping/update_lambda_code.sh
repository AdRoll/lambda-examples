#!/bin/sh -e
. env.sh

$(dirname $0)/lambda_template.sh

aws lambda update-function-code --region $REGION \
    --function-name $LAMBDA_LIFECYCLE_FUN \
    --zip-file fileb://lambda-code.zip

echo "updated lambda function code ($LAMBDA_LIFECYCLE_FUN)"
