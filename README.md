# Terraform Lambda Testing v2

Testing deploying Lambda Functions using Terraform, and also setting up Splunk APM (formerly known as SignalFx).

Deploys multiple Lambda Functions, which make up a small example micro-services application.

## terraform.tfvars

Rename 'terraform.tfvars.example' to 'terraform.tfvars' and update the values with your unique settings.  The AWS Variables assume you have aws cli configured and have a credentials file, typically located in ~/.aws

'profile' is the name of the aws profile from your ~/.aws/credentials file which tells the AWS CLI which account / environment to use.

'SFx Variables' are used to link to your SignalFx environment for APM

'Function URLs' point to the location of the source code for the Lambda Functions

    ### AWS Variables ###
    profile = "xxx"
    #region = "2"

    ### SFx Variables ###
    access_token = "xxx"
    realm = "eu0"
    metrics_url = "https://ingest.eu0.signalfx.com"
    metrics_tracing = "https://ingest.eu0.signalfx.com/v2/trace"
    apm_environment = "https://ingest.eu0.signalfx.com/v2/trace"

    ### Function URLs ###
    ### If populated here, will override the default values listed in variables.tf ###
    function_one_url = "tbc"
    function_two_url = "tbc"

## Deployment
Run the following commands - has been tested with terraform v0.13.4

    terraform init
    terraform apply
