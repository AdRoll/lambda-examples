#!/bin/sh -e
#
#    Creates and configures a security group for the example.  If your
#    IP address changes, re-run this script.
#
. env.sh

SG_ID=$(aws ec2 describe-security-groups --region $REGION \
             --group-names $SG_NAME --output text \
             --query 'SecurityGroups[].GroupId' || true)

if [ -z "$SG_ID" ] || [ "None" = "$SG_ID" ]; then
    SG_ID=$(aws ec2 create-security-group --region $REGION \
                --group-name $SG_NAME \
                --description "lambda example instance security group" \
                --output text --query 'GroupId')
    echo "created security group $SG_NAME ($SG_ID)"
else
    echo "$SG_NAME already exists ($SG_ID), not creating it"
fi

IP=$(curl http://checkip.amazonaws.com)
echo "authorizing $IP to access $SG_ID via ssh"

aws ec2 authorize-security-group-ingress --region $REGION \
    --group-id $SG_ID \
    --protocol tcp \
    --port 22 \
    --cidr ${IP}/32 || true

echo "re-run $0 if your IP address changes"
