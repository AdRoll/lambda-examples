#!/bin/sh -e
. env.sh

update_function () {
    FUN="$1"
    WHICH="$2"
    BUNDLE="lambda-code-${WHICH}.zip"
    MODULE="lambda_${WHICH}"

    zip -j "$BUNDLE" "${MODULE}.py"

    aws lambda update-function-code --region $REGION \
        --function-name $FUN \
        --zip-file fileb://$BUNDLE && \
        echo "updated function code of $FUN"
}

update_function $VALIDATOR_FUNCTION validator
update_function $EXECUTOR_FUNCTION executor
