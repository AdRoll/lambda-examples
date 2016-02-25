#!/bin/sh -e
. env.sh

LAMBDA_ASSUMEROLE_POLICY=$(python -c "import json; print json.dumps(
  {  'Version': '2012-10-17',
   'Statement': [{      'Sid': '',
                     'Effect': 'Allow',
                  'Principal': {'Service': 'lambda.amazonaws.com'},
                     'Action': 'sts:AssumeRole'
                 }] })")

LAMBDA_LIFECYCLE_ROLE_ARN=$(aws iam get-role --region $REGION \
                               --role-name $LAMBDA_LIFECYCLE_ROLE \
                               --output text --query 'Role.Arn' || true)

if [ -z "$LAMBDA_LIFECYCLE_ROLE_ARN" ] || [ "None" = "$LAMBDA_LIFECYCLE_ROLE_ARN" ]; then
    LAMBDA_LIFECYCLE_ROLE_ARN=$(aws iam create-role --region $REGION \
                                    --role-name $LAMBDA_LIFECYCLE_ROLE \
                                    --assume-role-policy-document "$LAMBDA_ASSUMEROLE_POLICY" \
                                    --output text \
                                    --query 'Role.Arn')
    echo "created $LAMBDA_LIFECYCLE_ROLE_ARN"
    echo "sleeping..."
    sleep 60
fi

echo "lambda execution role: $LAMBDA_LIFECYCLE_ROLE_ARN"


ACCOUNT=$(echo $LAMBDA_LIFECYCLE_ROLE_ARN | awk -F':' '{print $5}')

POLICY=$(python -c "import json; print json.dumps(
 {
    'Version': '2012-10-17',
    'Statement': [
        { 'Effect': 'Allow',
          'Action': ['logs:PutLogEvents',
                     'logs:CreateLogStream'],
          'Resource': 'arn:aws:logs:$REGION:$ACCOUNT:log-group:/aws/lambda/${LAMBDA_LIFECYCLE_FUN}:*' },

        { 'Effect': 'Allow',
          'Action': ['dynamodb:UpdateItem',
                     'dynamodb:GetItem',
                     'dynamodb:DeleteItem'],
          'Resource': 'arn:aws:dynamodb:$REGION:$ACCOUNT:table/$TABLE_NAME' },

        { 'Effect': 'Allow',
          'Action': ['sqs:ListQueues',
                     'sqs:GetQueueAttributes',
                     'sqs:CreateQueue'],
          'Resource': 'arn:aws:sqs:*:$ACCOUNT:*' },

        { 'Effect': 'Allow',
          'Action': ['sqs:DeleteQueue'],
          'Resource': 'arn:aws:sqs:*:$ACCOUNT:${PREFIX}_*' },

        { 'Effect': 'Allow',
          'Action': ['sns:Subscribe',
                     'sns:Unsubscribe'],
          'Resource': 'arn:aws:sns:$REGION:$ACCOUNT:${GLOBAL_TOPIC}*' },

        { 'Effect': 'Allow',
          'Action': ['autoscaling:CompleteLifecycleAction'],
          'Resource': '*' }
    ]
 })")

aws iam put-role-policy --region $REGION \
    --role-name $LAMBDA_LIFECYCLE_ROLE \
    --policy-name policy \
    --policy-document "$POLICY"

echo "installed policy on $ROLE_NAME (policy)"
