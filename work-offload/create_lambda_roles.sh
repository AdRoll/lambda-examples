#!/bin/sh -e
. env.sh

ROLE_ARN=""
create_role () {
    ROLE="$1"
    ASSUMEROLE_POLICY=$(python -c "import json; print json.dumps(
    {  'Version': '2012-10-17',
     'Statement': [{      'Sid': '',
                       'Effect': 'Allow',
                    'Principal': {'Service': 'lambda.amazonaws.com'},
                       'Action': 'sts:AssumeRole'
                   }] })")
    ROLE_ARN=$(aws iam get-role --region $REGION \
                   --role-name "$ROLE" \
                   --output text --query 'Role.Arn' || true)
    if [ -z "$ROLE_ARN" ] || [ "None" = "$ROLE_ARN" ]; then
        ROLE_ARN=$(aws iam create-role --region $REGION \
                       --role-name "$ROLE" \
                       --assume-role-policy-document "$ASSUMEROLE_POLICY" \
                       --output text \
                       --query 'Role.Arn')
        echo "created $ROLE_ARN"
        echo "sleeping..."
        sleep 60
    else
        echo "lambda role $ROLE_ARN already exists"
    fi
}
create_role $VALIDATOR_ROLE
create_role $EXECUTOR_ROLE

ACCOUNT=$(echo $ROLE_ARN | awk -F':' '{print $5}')

add_log_policy () {
    FUN="$1"
    ROLE="$2"
    POLICY_NAME="${3:-cloudwatch-policy}"
    POLICY=$(python -c "import json; print json.dumps(
    {
       'Version': '2012-10-17',
       'Statement': [
           { 'Effect': 'Allow',
             'Action': ['logs:PutLogEvents',
                        'logs:CreateLogStream'],
             'Resource': 'arn:aws:logs:$REGION:$ACCOUNT:log-group:/aws/lambda/${FUN}:*' }
       ]
    })")
    aws iam put-role-policy --region $REGION \
        --role-name "$ROLE" \
        --policy-name "$POLICY_NAME" \
        --policy-document "$POLICY"
    echo "installed policy on $ROLE ($POLICY_NAME)"
}

add_log_policy $VALIDATOR_FUNCTION $VALIDATOR_ROLE
add_log_policy $EXECUTOR_FUNCTION $EXECUTOR_ROLE


POLICY=$(python -c "import json; print json.dumps(
  {
     'Version': '2012-10-17',
     'Statement': [
         {  'Effect': 'Allow',
            'Action': ['dynamodb:Scan'],
          'Resource': 'arn:aws:dynamodb:$REGION:$ACCOUNT:table/$TABLE_NAME' },

         {  'Effect': 'Allow',
            'Action': ['sqs:ListQueues',
                       'sqs:GetQueueUrl',
                       'sqs:GetQueueAttributes'],
          'Resource': 'arn:aws:sqs:*:$ACCOUNT:*' },

         {  'Effect': 'Allow',
            'Action': ['sqs:SendMessage'],
          'Resource': 'arn:aws:sqs:*:$ACCOUNT:${PREFIX}_*' }
     ]
  })")
aws iam put-role-policy --region $REGION \
    --role-name "$EXECUTOR_ROLE" \
    --policy-name "work-dispatch-policy" \
    --policy-document "$POLICY" && \
    echo "installed policy on $EXECUTOR_ROLE (work-dispatch-policy)"
