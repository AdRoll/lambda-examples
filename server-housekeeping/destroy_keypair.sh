#!/bin/sh
. env.sh

EXISTS=$(aws ec2 describe-key-pairs --region $REGION \
             --key-names "$KEY_NAME" \
             --output text --query 'KeyPairs.KeyName' || true)

if [ ! -z "$EXISTS" ]; then
    aws ec2 delete-key-pair --region $REGION \
        --key-name "$KEY_NAME" && \
        rm -f "$KEY_FILE" && \
        echo "deleted keypair $KEY_NAME"
fi
