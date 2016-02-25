#!/bin/sh -e
#
#  Creates a launch configuration for the example.  The autoscaling
#  group we'll create will use it.
#
. env.sh

cat user_data.sh.src \
    | sed -e "s|%%PREFIX%%|$PREFIX|g" \
          -e "s|%%BUCKET%%|$BUCKET|g" \
          -e "s|%%BUCKET_PREFIX%%|$BUCKET_PREFIX|g" > user_data.sh

EXISTS=$(aws autoscaling describe-launch-configurations --region $REGION \
             --launch-configuration-names $LC_NAME \
             --output text --query 'LaunchConfigurations[0].LaunchConfigurationName' || true)

if [ -z "$EXISTS" ] || [ "None" = "$EXISTS" ]; then
    aws autoscaling create-launch-configuration --region $REGION \
        --launch-configuration-name $LC_NAME \
        --image-id $AMI \
        --key-name $KEY_NAME \
        --security-groups $SG_NAME \
        --instance-type t1.micro \
        --user-data fileb://user_data.sh \
        --instance-monitoring Enabled=false \
        --iam-instance-profile $ROLE_NAME
    echo "created launch configuration $LC_NAME"
else
    echo "launch config $LC_NAME already exists, not creating"
fi
