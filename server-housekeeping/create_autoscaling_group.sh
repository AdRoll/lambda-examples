#!/bin/sh -e
#
#
#
. env.sh

EXISTS=$(aws autoscaling describe-auto-scaling-groups --region $REGION \
             --auto-scaling-group-names $ASG_NAME \
             --output text --query 'AutoScalingGroups[0].AutoScalingGroupARN' || true)

if [ -z "$EXISTS" ] || [ "None" = "$EXISTS" ]; then
    aws autoscaling create-auto-scaling-group --region $REGION \
        --auto-scaling-group-name $ASG_NAME \
        --launch-configuration-name $LC_NAME \
        --availability-zones $ZONES \
        --tags ResourceId=$ASG_NAME,ResourceType=auto-scaling-group,Key=application,Value=$PREFIX,PropagateAtLaunch=true \
        --min-size 0 --max-size 10 \
        --desired-capacity 0
    echo "created autoscaling group $ASG_NAME"
else
    echo "$ASG_NAME already exists, not creating"
fi
