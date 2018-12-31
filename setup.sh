#!/bin/bash

# codecommit
aws codecommit create-repository --repository-name serverless-share-api
git clone --mirror https://github.com/nihemak/serverless-share-api.git serverless-share-api
cd serverless-share-api
git push ssh://git-codecommit.ap-northeast-1.amazonaws.com/v1/repos/serverless-share-api --all
cd ..

# iam lambda execute role
cat <<EOF > Trust-Policy.json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "lambda.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF
EXECUTE_ROLE=$(aws iam create-role --role-name serverless-share-api-execute \
                                   --assume-role-policy-document file://Trust-Policy.json)
cat <<EOF > Permissions.json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": [
                "arn:aws:logs:ap-northeast-1:${aws_account_id}:log-group:/aws/lambda/${cloudformation_api_stack}-*"
            ],
            "Effect": "Allow"
        }
    ]
}
EOF
aws iam create-policy \
        --policy-name serverless-share-api-execute \
        --policy-document file://Permissions.json
EXECUTE_ROLE_ARN=$(echo $EXECUTE_ROLE |jq -r ".Role.Arn")

# s3 deploy bucket
aws s3 mb s3://serverless-share-api-deploy-bucket --region ap-northeast-1

# iam build role
cat <<EOF > Trust-Policy.json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "codebuild.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF
BUILD_ROLE=$(aws iam create-role --role-name serverless-share-api-build \
                                 --assume-role-policy-document file://Trust-Policy.json)
aws iam attach-role-policy --policy-arn arn:aws:iam::aws:policy/AdministratorAccess \
                           --role-name serverless-share-api-build
BUILD_ROLE_ARN=$(echo $BUILD_ROLE |jq -r ".Role.Arn")

# codebuild
cat <<EOF > Source.json
{
  "type": "CODECOMMIT",
  "location": "https://git-codecommit.ap-northeast-1.amazonaws.com/v1/repos/serverless-share-api",
  "buildspec": "buildspec.yml"
}
EOF
cat <<EOF > Artifacts.json
{
  "type": "NO_ARTIFACTS"
}
EOF
cat <<EOF > Environment.json
{
  "type": "LINUX_CONTAINER",
  "image": "aws/codebuild/nodejs:8.11.0",
  "computeType": "BUILD_GENERAL1_SMALL",
  "environmentVariables": [
    {
      "name": "STAGE_ENV",
      "value": "test",
      "type": "PLAINTEXT"
    },
    {
      "name": "SERVICE_NAME",
      "value": "serverless-share-api",
      "type": "PLAINTEXT"
    },
    {
      "name": "LAMBDA_ROLE",
      "value": "${EXECUTE_ROLE_ARN}",
      "type": "PLAINTEXT"
    },
    {
      "name": "DEPLOY_BUCKET",
      "value": "serverless-share-api-deploy-bucket",
      "type": "PLAINTEXT"
    }
  ]
}
EOF
aws codebuild create-project --name serverless-share-api-test \
                               --source file://Source.json \
                               --artifacts file://Artifacts.json \
                               --environment file://Environment.json \
                               --service-role ${BUILD_ROLE_ARN}

aws codebuild start-build --project-name serverless-share-api-test
