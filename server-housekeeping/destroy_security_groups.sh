#!/bin/sh
. env.sh

aws ec2 delete-security-group --region $REGION \
    --group-name $SG_NAME && \
    echo "deleted security group $SG_NAME"

exit 0
