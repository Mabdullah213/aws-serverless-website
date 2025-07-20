import json
import boto3

dynamodb = boto3.resource('dynamodb')
# IMPORTANT: This now points to the new 'v8' table name
table = dynamodb.Table('visitor-counter-v8') 

def lambda_handler(event, context):
    try:
        response = table.update_item(
            Key={'PK': 'resume-visitor-count'},
            UpdateExpression='ADD #c :inc',
            ExpressionAttributeNames={'#c': 'count'},
            ExpressionAttributeValues={':inc': 1},
            ReturnValues="UPDATED_NEW"
        )
        new_count = response['Attributes']['count']
        return {
            'statusCode': 200,
            'headers': {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Headers': 'Content-Type',
                'Access-Control-Allow-Methods': 'POST'
            },
            'body': json.dumps({'count': str(new_count)})
        }
    except Exception as e:
        print(f"Error: {e}")
        return {
            'statusCode': 500,
            'headers': {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Headers': 'Content-Type',
                'Access-Control-Allow-Methods': 'POST'
            },
            'body': json.dumps({'error': 'Could not process the request.'})
        }
