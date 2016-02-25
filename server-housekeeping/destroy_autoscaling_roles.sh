#!/bin/sh
. env.sh

aws iam remove-role-from-instance-profile --region $REGION \
    --instance-profile-name $ROLE_NAME \
    --role-name $ROLE_NAME && \
    echo "removed $ROLE_NAME from instance profile"

aws iam delete-instance-profile --region $REGION \
    --instance-profile-name $ROLE_NAME && \
    echo "deleted instance profile $ROLE_NAME"

aws iam delete-role-policy --region $REGION \
    --role-name $ROLE_NAME \
    --policy-name $WORKER_POLICY_NAME && \
    echo "deleted role policy $WORKER_POLICY_NAME on $ROLE_NAME"

aws iam delete-role --region $REGION \
    --role-name $ROLE_NAME && \
    echo "deleted role $ROLE_NAME"

exit 0
