#
#  This isn't meant to be an example of a good way of managing
#  infrastructure.  It suffices for this toy example, though.
#
all: create-all

create-all: asg lifecycle dynamo lambda global-topic scale-up

asg: keypair security-groups asg-roles
	./create_launch_config.sh
	./create_autoscaling_group.sh

keypair:
	./create_keypair.sh

security-groups:
	./create_security_groups.sh

asg-roles:
	./create_autoscaling_roles.sh


lifecycle: lifecycle-roles lifecycle-hooks

lifecycle-roles:
	./create_lifecycle_roles.sh

lifecycle-hooks:
	./create_lifecycle_hooks.sh


dynamo:
	./create_tables.sh


lambda: lambda-roles lambda-functions

lambda-roles:
	./create_lambda_roles.sh

lambda-functions:
	./create_lambda_function.sh

lambda-update:
	./update_lambda_code.sh

scale-up:
	./scale_up.sh

global-topic:
	./create_global_topic.sh


destroy-all: destroy-asg-all destroy-lambda destroy-lifecycle destroy-dynamo destroy-topics


destroy-asg-all: destroy-asg destroy-asg-roles destroy-sg destroy-keypair

destroy-asg:
	./destroy_autoscaling_group.sh

destroy-asg-roles:
	./destroy_autoscaling_roles.sh

destroy-sg:
	./destroy_security_groups.sh

destroy-keypair:
	./destroy_keypair.sh


destroy-lambda:
	./destroy_lambda_function.sh
	./destroy_lambda_roles.sh


destroy-lifecycle:
	./destroy_lifecycle_roles.sh


destroy-dynamo:
	./destroy_tables.sh


destroy-topics:
	./destroy_sns_topics.sh
