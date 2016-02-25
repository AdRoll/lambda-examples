#!/bin/sh
. env.sh

aws autoscaling delete-auto-scaling-group --region $REGION \
    --auto-scaling-group-name $ASG_NAME --force-delete && \
    echo "deleted autoscaling group $ASG_NAME"


while [ "None" != $(aws autoscaling describe-auto-scaling-groups --region $REGION \
                        --auto-scaling-group-names $ASG_NAME \
                        --output text --query 'AutoScalingGroups[0].AutoScalingGroupARN') ]; do
    echo "waiting for asg deletion..."
    sleep 30
done

aws autoscaling delete-launch-configuration --region $REGION \
    --launch-configuration-name $LC_NAME && \
    echo "deleted launch configuration $LC_NAME"

exit 0
