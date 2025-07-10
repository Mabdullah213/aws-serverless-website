import json
import boto3

# Initialize the DynamoDB client
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('visitor-counter')

def lambda_handler(event, context):
    """
    Updates and retrieves the visitor count from DynamoDB.
    """
    try:
        # Get the current count and update it by 1
        response = table.update_item(
            Key={'PK': 'resume-visitor-count'},
            UpdateExpression='ADD #c :inc',
            ExpressionAttributeNames={'#c': 'count'},
            ExpressionAttributeValues={':inc': 1},
            ReturnValues="UPDATED_NEW"
        )

        # Get the new count from the response
        new_count = response['Attributes']['count']

        # Return a successful response with CORS headers
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
        # Handle any errors
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