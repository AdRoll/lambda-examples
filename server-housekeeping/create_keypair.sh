#!/bin/sh -e
#
#    Creates a keypair for use with the example.
#
. env.sh

if [ ! -f "$KEY_FILE" ]; then
    echo "creating key ${KEY_NAME} in ${KEY_FILE}..."
    aws ec2 create-key-pair --region $REGION \
        --output text --query 'KeyMaterial'  \
        --key-name $KEY_NAME  > $KEY_FILE
    chmod 0600 $KEY_FILE
    echo "created $KEY_FILE"
else
    echo "$KEY_FILE exists, not recreating it"
fi
