#!/bin/sh
. env.sh

aws iam delete-role-policy --region $REGION \
    --role-name $LAMBDA_LIFECYCLE_ROLE \
    --policy-name policy && \
    echo "deleted role policy on $LAMBDA_LIFECYCLE_ROLE"

aws iam delete-role --region $REGION \
    --role-name $LAMBDA_LIFECYCLE_ROLE && \
    echo "deleted role $LAMBDA_LIFECYCLE_ROLE"

exit 0
