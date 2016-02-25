#!/bin/sh -e
. env.sh

aws autoscaling set-desired-capacity --region $REGION \
    --auto-scaling-group-name $ASG_NAME \
    --desired-capacity 1
