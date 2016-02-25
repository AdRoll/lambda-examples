export REGION="us-east-1"
export ZONES="${REGION}a ${REGION}b ${REGION}d ${REGION}e" # change if not us-east-1

export AMI="ami-d4f7ddbe" # pv ebs amazon linux ami in us-east-1
export PREFIX="lambda-example"

export KEY_FILE="$PREFIX-key.rsa"
export KEY_NAME="$PREFIX-key-1"

export SG_NAME="$PREFIX-sg"

export LC_NAME="$PREFIX-lc"

export ROLE_NAME="$PREFIX-role"

export ASG_NAME="$PREFIX-asg"

export WORKER_POLICY_NAME="access-example-queue"

export BUCKET="${BUCKET:-$PREFIX}"
export BUCKET_PREFIX="${BUCKET_PREFIX:-example-data}"

export LIFECYCLE_NOTIF_ROLE="$PREFIX-lifecycle-notif"
export LIFECYCLE_TOPIC="${ASG_NAME}-lifecycle"
export LIFECYCLE_POLICY_NAME="lifecycle-updates"

export LAMBDA_LIFECYCLE_FUN="$PREFIX-lifecycle-handler"
export LAMBDA_LIFECYCLE_ROLE="$LAMBDA_LIFECYCLE_FUN-role"

export TABLE_NAME="Test_${PREFIX}"
export GLOBAL_TOPIC="$PREFIX-global-commands"
