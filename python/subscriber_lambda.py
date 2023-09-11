import boto3
import logging
import os

logger = logging.getLogger()
logger.setLevel(logging.INFO)

sns_client = boto3.client("sns", region_name=os.environ["AWS_REGION"])

def subscribe(email_address):
    # logger.debug(f"Subscribing to SNS", email_address=email_address)

    response = sns_client.subscribe(
        TopicArn=os.environ["SNS_TOPIC_ARN"],
        Protocol="email",
        Endpoint=email_address,
        ReturnSubscriptionArn=False
    )
    return response

# need to workout how to confirm email address then
# def confirm():
#     response = sns_client.confirm_subscription(
#     TopicArn=os.environ["SNS_TOPIC_ARN"],
#     Token='string', 
#     AuthenticateOnUnsubscribe=False
# )

def handler(event, lambda_context):
    # logger.debug(f"DynamoDB has invoked function", event=event)

    email_address = event["Records"][0]["dynamodb"]["NewImage"]["email"]["S"]
    response = subscribe(email_address=email_address)
    
    return response
