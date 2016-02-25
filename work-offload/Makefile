all: lambda run

lambda:
	./create_lambda_roles.sh
	./create_lambda_functions.sh
	./update_code.sh

destroy-all: destroy-lambda

destroy-lambda:
	./destroy_lambda_functions.sh
	./destroy_lambda_roles.sh

run:
	sh -c 'source env.sh && python server.py'
