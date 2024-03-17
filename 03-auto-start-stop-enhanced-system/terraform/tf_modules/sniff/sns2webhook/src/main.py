# std lib
import datetime
import json
import os
import logging
import requests

ENV = os.getenv("ENV", "dev")
APP = os.getenv("APP", "")
# logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(__name__)
logger.setLevel(level=logging.DEBUG)

# Const
WEBHOOK_URL = os.getenv("WEBHOOK_URL", "https://discord.com/api/webhooks/1163846001837219881/oYmCeoHZxNPygZmet5e7oe1aNkWm9TC0I8tivbhktHePyo0EyscZIC7Xj8YrHbVVeojJ")

def create_payload_eventbridge(event):
    message = json.loads(event["Message"])
    subject = message["detail-type"]
    event_name = message["detail"]["eventName"]
    event_reason = message["detail"]["reason"]
    event_region = message["region"]
    #"resources":["arn:aws:ecs:us-east-1:086738740584:service/hosttools-beta-web/hosttools-beta-web"]
    env = message["resources"][0].split("/")[-1].split("-")[1]
    component = message["resources"][0].split("/")[-1].split("-")[2]


    description = f"""
+ Event Name  : **{event_name.upper()}**
+ Reason      : {event_reason}
+ Environment : **{env.upper()}**
+ Component   : **{component.upper()}**
"""

    return {
        'embeds': [
            {
                'title': 'AWS EventBridge: ' + subject,
                'description': description,
                'color': 0xFF0000,
                'timestamp': event["Timestamp"],
            }
        ]
    }

def create_payload_cloudwatch(event):
    subject = event["Subject"]
    message = json.loads(event["Message"])
    alarm_region = message["AlarmArn"].split(":")[3]
    alarm_name = message["AlarmName"]
    alarm_desc = message["AlarmDescription"]
    env = message["AlarmName"].split("-")[1]
    component = message["AlarmName"].split("-")[2]
  
    description = f"""
+ Alarm Name  : **{alarm_name.upper()}**
+ Description : {alarm_desc}
+ Environment : **{env.upper()}**
+ Component   : **{component.upper()}**
+ URL         : https://{alarm_region}.console.aws.amazon.com/cloudwatch/home?region={alarm_region}#alarmsV2:alarm/{alarm_name}
"""

    return {
        'embeds': [
            {
                'title': 'AWS Cloudwatch: ' + subject,
                'description': description,
                'color': 0xFF0000,
                'timestamp': event["Timestamp"],
            }
        ]
    }

def lambda_handler(event, _context):
    logger.info("event: {}".format(json.dumps(event)))
    event_message = event["Records"][0]["Sns"]["Message"]
    if "detail-type" in event_message:
        event_type = "EventBridge"
        message = create_payload_eventbridge(event["Records"][0]["Sns"])
    elif "AlarmName" in event_message:
        event_type = "CloudWatchAlarm"
        message = create_payload_cloudwatch(event["Records"][0]["Sns"])
    else:
       event_type = None
       logger.error("Unsupported event type")
       return
    
    requests.post(
       WEBHOOK_URL, 
       data=json.dumps(message),
       headers={
          'Content-Type': 'application/json',
        },
    )

    return True
