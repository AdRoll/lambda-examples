#!/bin/sh
. env.sh

aws iam delete-role-policy --region $REGION \
    --role-name $LIFECYCLE_NOTIF_ROLE \
    --policy-name $LIFECYCLE_POLICY_NAME && \
    echo "deleted role policy $LIFECYCLE_POLICY_NAME on $LIFECYCLE_NOTIF_ROLE"

aws iam delete-role --region $REGION \
    --role-name $LIFECYCLE_NOTIF_ROLE && \
    echo "deleted role $LIFECYCLE_NOTIF_ROLE"

exit 0
