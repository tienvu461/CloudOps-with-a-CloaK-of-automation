import boto3
import os
import sys
import logging
import json

logging.basicConfig(level=logging.INFO, format=('%(asctime)s %(name)s %(lineno)d: %(levelname)s\t%(message)s'))
logger = logging.getLogger(__name__)
formatter = logging.Formatter ()
logger.setLevel(level=logging.INFO)

# ENVIRONMENT VARS
AWS_REGION = os.getenv("AWS_REGION", "ap-southeast-1")

# CONST
NBD = "NBD" #Normal Business Day - 9h - 18h
EOB = "EOB" #End of Business - 18h
SOB = "SOB" #Start of Business - 9h

# Ass type from EventBrigde scheduler
def get_ass_type(event):
    event_resource_name = event['resources'][0]
    return event_resource_name.split('/')[1]

def list_instances(ec2_client, ass_filter=[]):
    resp = ec2_client.describe_instances(
        Filters=ass_filter
    )
    instances = []
    for r in resp['Reservations']:
        for i in r['Instances']:
            logger.debug(i)
            logger.debug(i['InstanceId'])
            logger.debug(i['Tags'])
            instances.append(i['InstanceId'])
    return instances

def eob_execution(ec2_client, instances):
    logger.debug(f"Stopping instance {instances} with EOB/NBD tag")
    try:
        response = ec2_client.stop_instances(
            InstanceIds=instances,
            # DryRun=True
        )
    except Exception as e:
        logger.error(f"Fail to stop instance(s). Reason: {e}")
        raise e
    
def sob_execution(ec2_client, instances):
    logger.debug(f"Starting instance {instances} with SOB/NBD tag")
    try:
        response = ec2_client.start_instances(
            InstanceIds=instances,
            # DryRun=True
        )
    except Exception as e:
        logger.error(f"Fail to start instance(s). Reason: {e}")
        raise e

def lambda_handler(event, context):
    logger.info("event: {}".format(json.dumps(event)))
    ass_type = get_ass_type(event)
    ec2_client = boto3.client('ec2', region_name=AWS_REGION)
    if ass_type == "EOB":
        eob_filter = [
            {
                "Name" : "tag:ASS",
                "Values": [
                    "NBD",
                    "EOB"
                ]
            },
            {
                "Name": "instance-state-name",
                "Values": ["running",]
            }
        ]
        eob_instances = list_instances(ec2_client, ass_filter=eob_filter)
        if eob_instances:
            logger.info(f"The following list of instances will be stopped: {eob_instances}")
            eob_execution(ec2_client, eob_instances)
        else:
            logger.info("Cannot find any instance met condition")
    elif ass_type == "SOB":
        sob_filter = [
            {
                "Name" : "tag:ASS",
                "Values": [
                    "NBD",
                    "SOB"
                ]
            },
            {
                "Name": "instance-state-name",
                "Values": ["stopped",]
            }
        ]
        sob_instances = list_instances(ec2_client, ass_filter=sob_filter)
        if sob_instances:
            logger.info(f"The following list of instances will be started: {sob_instances}")
            sob_execution(ec2_client, sob_instances)
        else:
            logger.info("Cannot find any instance met condition")
