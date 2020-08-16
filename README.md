# Python SQS Consumer Example

A simple example SQS consumer written in Python featuring:

* CloudFormation for AWS resources (not including container orchestration)
* SNS/SQS subscription
* Deadletter queue
* Docker environment

## Setup

### Create the AWS resources via Cloud Formation

```shell
export AWS_REGION=us-east-1
export PROFILE='your-aws-creds-profile-name-here'
# developer rolename is the IAM role your developers assume, so we can allow
# the role for this service to be assumed by that role as well as by ECS, etc.
export DEVELOPER_ROLENAME='your-developer-role-name-here'

# create the stack
aws cloudformation create-stack \
    --stack-name sqs-helloworld \
    --capabilities CAPABILITY_NAMED_IAM \
    --parameters ParameterKey=DeveloperRolename,ParameterValue=$DEVELOPER_ROLENAME \
    --template-body file://cloudformation.yml --profile $PROFILE
```

### Build your Docker container

```shell
docker build -t python-sqs-consumer-example:latest .
```

## Run Locally

```shell
AWS_REGION=us-east-1
PROFILE='your-aws-creds-profile-name-here'

# iam-docker-run will generate temp credentials for the role used by the sqs consumer
# using your local profile, and it will pass these creds into the container using
# environment variables.  In this way you are running with the least privilege
# role created for the service rather than your developer credentials.

# pip install iam-docker-run
iam-docker-run \
    --interactive \
    -e AWS_REGION=$AWS_REGION \
    -e SQSCONSUMER_QUEUENAME=example-helloworld-requests \
    --image python-sqs-consumer-example:latest \
    --profile $PROFILE \
    --role role-example-sqsconsumer
```

## Test

```shell
AWS_REGION=us-east-1
PROFILE='your-aws-creds-profile-name-here'
AWS_ACCOUNTID=$(aws sts get-caller-identity --query 'Account' --output text --profile $PROFILE)
TEST_TOPIC_ARN="arn:aws:sns:$AWS_REGION:$AWS_ACCOUNTID:test-example-hello-request"

# run the sqs consumer using the test queue
iam-docker-run \
    --interactive \
    -e AWS_REGION=$AWS_REGION \
    -e SQSCONSUMER_QUEUENAME=test-example-helloworld-requests \
    --image python-sqs-consumer-example:latest \
    --profile $PROFILE \
    --role role-example-sqsconsumer

# post a test message to the test queue
aws sns publish \
    --topic-arn $TEST_TOPIC_ARN \
    --message "testing hello world" \
    --profile $PROFILE
```
