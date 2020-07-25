import boto3
import json
from random import randrange

pageview_stream_name = 'pageview_stream'
user_stream_name = 'user_stream'
kinesis_client = boto3.client('kinesis', region_name='eu-west-2')
postcodes = ["SW19", "SW18", "SW17", "NW10", "NW8", "SE1", "SE10", "SE9", "NE10", "NE12"]


def put_user(user_id, postcode):
    payload = {
        'user_id': user_id,
        'postcode': postcode
    }

    put_response = kinesis_client.put_record(
        StreamName=user_stream_name,
        Data=json.dumps(payload),
        PartitionKey=user_id
    )


def put_pageview(user_id, url):
    payload = {
        'user_id': user_id,
        'url': url
    }

    put_response = kinesis_client.put_record(
        StreamName=pageview_stream_name,
        Data=json.dumps(payload),
        PartitionKey=user_id
    )


def main():
    counter = 0
    while counter < 500:
        user_id = f"user{str(randrange(10)+1)}"
        url = f"page{str(randrange(10)+1)}"
        postcode = postcodes[randrange(10)]
        put_user(user_id, postcode)
        put_pageview(user_id, url)
        counter += 1


if __name__ == "__main__":
    main()
