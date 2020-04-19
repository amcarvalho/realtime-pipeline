import boto3
import base64
import json


def user_consumer(event, context):
    dynamodb = boto3.resource('dynamodb', region_name='eu-west-2')
    table = dynamodb.Table('user_table')
    for record in event['Records']:
        payload = base64.b64decode(record['kinesis']['data'])
        result = json.loads(payload)
        user_id = result['user_id']
        postcode = result['postcode']
        table.put_item(
            Item={
                'user_id': user_id,
                'postcode': postcode
            }
        )
        print(f"User {user_id} lives in {postcode}.")
