#!/bin/sh -e
. env.sh

EC2_ASSUMEROLE_POLICY=$(python -c "import json; print json.dumps(
  {  'Version': '2012-10-17',
   'Statement': [{      'Sid': '',
                     'Effect': 'Allow',
                  'Principal': {'Service': 'ec2.amazonaws.com'},
                     'Action': 'sts:AssumeRole'
                 }] })")


ROLE_ARN=$(aws iam get-role --region $REGION \
               --role-name $ROLE_NAME \
               --output text \
               --query 'Role.Arn' || true)
if [ -z "$ROLE_ARN" ] || [ "None" = "$ROLE_ARN" ]; then
    ROLE_ARN=$(aws iam create-role --region $REGION \
                   --role-name $ROLE_NAME \
                   --assume-role-policy-document "$EC2_ASSUMEROLE_POLICY" \
                   --output text \
                   --query 'Role.Arn')
fi
echo "autoscaling role: $ROLE_ARN"

PROFILE_ARN=$(aws iam get-instance-profile --region $REGION \
                  --instance-profile-name $ROLE_NAME \
                  --output text \
                  --query 'InstanceProfile.Arn' || true)

if [ -z "$PROFILE_ARN" ] || [ "None" = "$PROFILE_ARN" ]; then
    PROFILE_ARN=$(aws iam create-instance-profile --region $REGION \
                      --instance-profile-name $ROLE_NAME \
                      --output text \
                      --query 'InstanceProfile.Arn')
fi
echo "instance profile: $PROFILE_ARN"

PROFILE_ROLE_ARN=$(aws iam get-instance-profile --region $REGION \
                       --instance-profile-name $ROLE_NAME \
                       --output text \
                       --query 'InstanceProfile.Roles[0].Arn' || true)

if [ -z "$PROFILE_ROLE_ARN" ] || [ "None" = "$PROFILE_ROLE_ARN" ]; then
    aws iam add-role-to-instance-profile --region $REGION \
        --instance-profile-name $ROLE_NAME \
        --role-name $ROLE_NAME
    echo "added role to instance profile; sleeping..."
    sleep 30
fi


ACCOUNT=$(echo $ROLE_ARN | awk -F':' '{print $5}')

POLICY=$(python -c "import json; print json.dumps(
 {
    'Version': '2012-10-17',
    'Statement': [
        {
            'Effect': 'Allow',
            'Action': ['sqs:GetQueueUrl',
                       'sqs:ReceiveMessage',
                       'sqs:DeleteMessage',
                       'sqs:GetQueueAttributes'],
            'Resource': 'arn:aws:sqs:*:$ACCOUNT:$PREFIX_*'
        },
        {
            'Effect': 'Allow',
            'Action': ['s3:PutObject'],
            'Resource': 'arn:aws:s3:::$BUCKET/${BUCKET_PREFIX}*'
        }
    ]
 })")

aws iam put-role-policy --region $REGION \
    --role-name $ROLE_NAME \
    --policy-name $WORKER_POLICY_NAME \
    --policy-document "$POLICY"

echo "using policy $WORKER_POLICY_NAME on $ROLE_NAME"
