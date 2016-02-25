#!/bin/sh
. env.sh

destroy_lambda_role () {
    ROLE="$1"
    shift
    POLICIES="${@:-cloudwatch-policy}"
    for POLICY in $POLICIES; do
        aws iam delete-role-policy --region $REGION \
            --role-name $ROLE \
            --policy-name $POLICY && \
            echo "deleted role policy [$POLICY] on $ROLE"
    done

    aws iam delete-role --region $REGION \
        --role-name $ROLE && \
        echo "deleted role $ROLE"
}

destroy_lambda_role $VALIDATOR_ROLE
destroy_lambda_role $EXECUTOR_ROLE cloudwatch-policy work-dispatch-policy

exit 0
