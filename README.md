# AWS Lambda PoC

The purpose of this repo is to be a short example of implementing a AWS Lambda function with
Python.

The scenario of the code is the following:

- The lambda is triggered automatically by uploading a file to a "source S3 bucket"
- this uploaded file is read and filtered by the lambda
- the result of the lambda is output as a new parquet file to a "target S3 bucket"

## Requirements

- docker-compose: used for local testing
- Pipenv with Python3.8: Lambda Runtime
- Terraform: Terraform is used to create the resources and deploy the Lambda function
  - in order to use the aws terraform provider the local environment needs to be configured to be
    connected to an AWS account
- make: Used for development scripts

## Notes

### Pipenv and Pip

This project uses both pipenv and pip.

Pipenv is used to manage the python version (in accordance with the AWS runtime) and the local
development environment.

Pip (and the requirements.txt) is used to manage the third party libraries, which are packaged
together with the source code.

### Build environment

As some python packages contain compiled C code (e.g. numpy, which is required by pyarrow) a build
environment of Linux is needed. To accommodate MacOS and Windows users a dockerized build
environment is used here.

### First time applying (terraform dependency issue)

The first time terraform is applied it will complain about missing the source code file.
To solve this it is recommended to comment out the `lambda.tf` file completely and apply the
terraform files. Then uploading the source code once `make deploy` should solve the issue.
After that the `lambda.tf` file can be uncommented again and now everything show work as expected.
