#!/bin/sh -e
. env.sh

ASG_ASSUMEROLE_POLICY=$(python -c "import json; print json.dumps(
  {  'Version': '2012-10-17',
   'Statement': [{      'Sid': '',
                     'Effect': 'Allow',
                  'Principal': {'Service': 'autoscaling.amazonaws.com'},
                     'Action': 'sts:AssumeRole'
                 }] })")

LIFECYCLE_NOTIF_ROLE_ARN=$(aws iam get-role --region $REGION \
                               --role-name $LIFECYCLE_NOTIF_ROLE \
                               --output text --query 'Role.Arn' || true)

if [ -z "$LIFECYCLE_NOTIF_ROLE_ARN" ] || [ "None" = "$LIFECYCLE_NOTIF_ROLE_ARN" ]; then
    LIFECYCLE_NOTIF_ROLE_ARN=$(aws iam create-role --region $REGION \
                                   --role-name $LIFECYCLE_NOTIF_ROLE \
                                   --assume-role-policy-document "$ASG_ASSUMEROLE_POLICY" \
                                   --output text \
                                   --query 'Role.Arn')
    echo "sleeping..."
    sleep 60
fi

echo "lifecycle hook notification role: $LIFECYCLE_NOTIF_ROLE_ARN"

ACCOUNT=$(echo $LIFECYCLE_NOTIF_ROLE_ARN | awk -F':' '{print $5}')

LIFECYCLE_POLICY=$(python -c "import json; print json.dumps(
 {
    'Version': '2012-10-17',
    'Statement': [
        {
            'Effect': 'Allow',
            'Action': ['sns:Publish'],
            'Resource': 'arn:aws:sns:$REGION:$ACCOUNT:$LIFECYCLE_TOPIC'
        }
    ]
 })")

aws iam put-role-policy --region $REGION \
    --role-name $LIFECYCLE_NOTIF_ROLE \
    --policy-name $LIFECYCLE_POLICY_NAME \
    --policy-document "$LIFECYCLE_POLICY" && \
    echo "sleeping..." && sleep 30

echo "installed policy on $LIFECYCLE_NOTIF_ROLE ($LIFECYCLE_POLICY_NAME)"
