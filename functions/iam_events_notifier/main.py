import os
import boto3
import json
import gzip
import urllib3

BOTO_S3 = 's3'
S3_CLIENT = None
BUCKET_REGION = os.environ.get('BUCKET_REGION')
WEBHOOK_URL = os.environ.get('WEBHOOK_URL')

EVENTS_NOTIFIED = [
    'AddUserToGroup', 
    'CreateUser', 
    'ChangePassword',
    'CreateAccessKey', 
    'DeleteAccountPasswordPolicy',
    'DeleteRole',
    'DeleteRolePermissionsBoundary',
    'DeleteRolePolicy',
    'DeleteUser',
    'PutRolePermissionsBoundary',
    'PutRolePolicy',
    'PutUserPermissionsBoundary',
    'RemoveUserFromGroup',
    'UpdateAccessKey',
    'UpdateAccountPasswordPolicy',
    'UpdateAssumeRolePolicy',
    'UpdateRole',
    'UpdateSSHPublicKey',
    'UpdateUser',
    ]

def handler(event, context):
    global S3_CLIENT
    if not S3_CLIENT:
        S3_CLIENT = boto3.client(BOTO_S3)

    data = get_record(event['Records'][0])
    object_link = get_object_link(event['Records'][0])

    json_data = json.loads(data)
    print(f"Object contains {len(json_data['Records'])} records.")
    for event in json_data['Records']:
        event_name = event['eventName']
        event_source = event['eventSource']
        event_time = event['eventTime']
        aws_region = event['awsRegion']
        
        ressource_arn = event['responseElements']
        recipient_account_id = event['recipientAccountId']
        
        user_identity = event['userIdentity']['arn']
        source_ip_address = event['sourceIPAddress']
        user_agent = event['userAgent']
        if event_should_be_notified(event):
            print("Event should be notified, sending notification.")
            notify(f"""New event: {event_name}
                    Event source: {event_source} ({aws_region})
                    Event time: {event_time}
                    
                    AWS account: {recipient_account_id}
                    Ressource informations: {ressource_arn}

                    User identity: {user_identity}
                    Source IP: {source_ip_address}
                    User agent: {user_agent}

                    Complete records is available at:
                    {object_link}""")

# Function that check if the event should be notified
def event_should_be_notified(event):
    return event['eventName'] in EVENTS_NOTIFIED


# Function that get the link of the object in the s3 bucket
# take a record as a parameter
def get_object_link(record):
    try:
        s3_bucket = record['s3']['bucket']['name']
        s3_object_key = record['s3']['object']['key']
        return f"https://{s3_bucket}.s3.{BUCKET_REGION}.amazonaws.com/{s3_object_key}"
    except Exception as err:
        print(f"Error: {err}")

# Function that get the record from the s3 bucket
# take a record as a parameter
def get_record(record):
    try:
        s3_bucket = record['s3']['bucket']['name']
        s3_object_key = record['s3']['object']['key']
        s3_object = S3_CLIENT.get_object(Bucket=s3_bucket, Key=s3_object_key)
        body = s3_object['Body']

        # Check if the content is gzipped
        if s3_object.get('ContentEncoding') == 'gzip':
            with gzip.GzipFile(fileobj=body) as gz:
                data = gz.read().decode('utf-8')
                return data
        else:
            data = body.read().decode('utf-8')
            return data
    except Exception as err:
        print(f"Error: {err}")

# Function that send the notification to the webhook
# take a message as a parameter
def notify(msg):
    message = {"content": msg}
    encoded_message = json.dumps(message).encode('utf-8')

    http = urllib3.PoolManager()
    response = http.request('POST', WEBHOOK_URL, body=encoded_message, headers={'Content-Type': 'application/json'})
    if response.status == 204:
        print("Message sent successfully")
    else:
        raise RuntimeError(f"Failed to send message. Status code: {response.status}")