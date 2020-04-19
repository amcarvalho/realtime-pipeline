from datetime import datetime
import base64
import boto3
import json
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

kinesis_client = boto3.client('kinesis', region_name='eu-west-2')
dynamodb = boto3.resource('dynamodb', region_name='eu-west-2')
table = dynamodb.Table('user_table')


def pageview_consumer(event, context):
    for record in event['Records']:
        payload = base64.b64decode(record['kinesis']['data'])
        result = json.loads(payload)
        user_id = result['user_id']
        result['event_datetime'] = str(datetime.now())

        response = table.get_item(
            Key={
                'user_id': user_id
            },
            ConsistentRead=True
        )

        try:
            item = response['Item']
            postcode = item['postcode']
            result['postcode'] = postcode
        except KeyError:
            logger.info(f"User {user_id} postcode not found. Not enriching postcode.")

        put_response = kinesis_client.put_record(
            StreamName="enriched_pageview_stream",
            Data=json.dumps(result),
            PartitionKey=user_id
        )
