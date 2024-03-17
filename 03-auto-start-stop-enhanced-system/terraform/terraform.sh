#!/bin/bash

## Prerequisites:
## - s3 bucket for storing terraform state must be created
## - aws_profile must be setup in local ~/.aws/credentials or ~/.aws/config
##   either static credentials or assume roles can be used

set -e

while getopts ":e:c:a:" opt; do
    case $opt in
    e)
        ENV=$OPTARG
        ;;
    c)
        COMPONENT=$OPTARG
        ;;
    a)
        ACTION=$OPTARG
        ;;
    ?)
        echo "Invalid"
        exit 1
        ;;
    esac
done
# Get app config
APP_NAME="my-ground-breaking-application"
APP_PATH="$(pwd)/$APP_NAME"
app_config=$(cat $APP_PATH/app_config/config.json)
# Variables
REGION=$(echo "${app_config}" | jq -r '.aws_region')
S3_BACKEND_BUCKET=$(echo "${app_config}" | jq -r '.s3_backend_bucket')
AWS_PROFILE=$(echo "${app_config}" | jq -r '.aws_profile')
SCRIPT_PATH=$(pwd)
VAR_FILE="${APP_PATH}/tfvars/${ENV}/${COMPONENT}.tfvars"
case ${ENV} in
"dev") ENV_LONG="development" ;;
"prd") ENV_LONG="production" ;;
*) echo "Invalid env name" ;;
esac

# Functions
function init() {
    terraform init -input=false \
        -var-file=${VAR_FILE} \
        -backend-config="profile=${AWS_PROFILE}" \
        -backend-config="region=${REGION}" \
        -backend-config="bucket=${S3_BACKEND_BUCKET}" \
        -backend-config="key=${COMPONENT}.tfstate"
}
function plan() {
    local plan_output_file=$1
    terraform plan \
        -var-file=${VAR_FILE} \
        -lock=true -input=false \
        -out=${plan_output_file}
}
function apply() {
    local plan_output_file=$1
    terraform apply \
        -var-file=${VAR_FILE} \
        -lock=true \
        ${plan_output_file}
}
function run_terraform() {
    local COMPONENT=$1
    local ACTION=$2
    local PLAN_OUTPUT_FILE=$3
}

# Main execution
EXEC_DIR="${APP_PATH}/components/${COMPONENT}"
# validate component
if [[ -d "${EXEC_DIR}/" ]]; then
    echo "Terraform [${ACTION}] [${COMPONENT}]"
else
    echo "Invalid component."
    exit 1
fi
if [[ -z ${PLAN_OUTPUT_FILE} ]]; then
    PLAN_OUTPUT_FILE="${APP_PATH}/plan_output/${COMPONENT}.out"
fi

cd ${EXEC_DIR}
export AWS_PROFILE=${AWS_PROFILE}

if [[ ${ACTION} = "init" ]]; then
    init
elif [[ ${ACTION} = "plan" ]]; then
    plan ${PLAN_OUTPUT_FILE}
elif [[ ${ACTION} = "apply" ]]; then
    apply ${PLAN_OUTPUT_FILE}
else
    echo "Invalid action"
fi
