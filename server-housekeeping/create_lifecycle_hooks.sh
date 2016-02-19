#!/bin/sh -e
. env.sh

# note: re-running this returns the same topic:
TOPIC_ARN=$(aws sns create-topic --region $REGION \
                --name $LIFECYCLE_TOPIC \
                --output text --query 'TopicArn')

LIFECYCLE_ROLE_ARN=$(aws iam get-role --region $REGION \
                         --role-name $LIFECYCLE_NOTIF_ROLE \
                         --output text --query 'Role.Arn')

aws autoscaling put-lifecycle-hook --region $REGION \
    --lifecycle-hook-name launch-hook \
    --auto-scaling-group-name $ASG_NAME \
    --lifecycle-transition "autoscaling:EC2_INSTANCE_LAUNCHING" \
    --heartbeat-timeout 60 \
    --default-result CONTINUE \
    --role-arn $LIFECYCLE_ROLE_ARN \
    --notification-target-arn $TOPIC_ARN

echo "added lifecycle launch hook to $ASG_NAME"

aws autoscaling put-lifecycle-hook --region $REGION \
    --lifecycle-hook-name destroy-hook \
    --auto-scaling-group-name $ASG_NAME \
    --lifecycle-transition "autoscaling:EC2_INSTANCE_TERMINATING" \
    --heartbeat-timeout 60 \
    --default-result CONTINUE \
    --role-arn $LIFECYCLE_ROLE_ARN \
    --notification-target-arn $TOPIC_ARN

echo "added lifecycle destroy hook to $ASG_NAME"
