import json
import boto3
import uuid
import os

TABLE_NAME = os.environ.get("TODO_TABLE", "todo-table")
dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(TABLE_NAME)

def build_response(status, body):
    return {
        "statusCode": status,
        "headers": {
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Headers": "*",
            "Access-Control-Allow-Methods": "GET,POST,DELETE,OPTIONS"
        },
        "body": json.dumps(body)
    }

def lambda_handler(event, context):

    print("EVENT:", json.dumps(event))
    http_method = event.get("httpMethod") or event.get("requestContext", {}).get("http", {}).get("method")
  
    #HANDLE CORS preflight
    if http_method == "OPTIONS":
        return build_response(200, "")

    if http_method == "POST":
        return create_task(event)
    elif http_method == "GET":
        return list_tasks()
    elif http_method == "DELETE":
        return delete_task(event)
    elif http_method == "PUT":
        return update_task(event)
    else:
        return build_response(400, {"message": "Unsupported method"})

#CREATE Task

def create_task(event):
    try:
        body = json.loads(event.get("body", "{}"))
        task_text = body.get("task")
        if not task_text:
            return build_response(400, {"message": "Task text is required"})

        task_item = {"id": str(uuid.uuid4()), "task": task_text}
        table.put_item(Item=task_item)
        return build_response(200, task_item)

    except Exception as e:
        return build_response(500, {"error": str(e)})

#LIST Tasks

def list_tasks():
    try:
        response = table.scan()
        return build_response(200, response.get("Items", []))

    except Exception as e:
        return build_response(500, {"error": str(e)})

#DELETE Tasks

def delete_task(event):
    try:
        # Get task ID from path
        task_id = event.get("pathParameters", {}).get("id")

        if not task_id:
            return build_response(400, {"message": "Task ID is required"})

        table.delete_item(
            Key={"id": task_id}
        )

        return build_response(200, {"message": "Task deleted"})

    except Exception as e:
        return build_response(500, {"error": str(e)})

#UPDATE Tasks

def update_task(event):
    try:
        task_id = event.get("pathParameters", {}).get("id")
        body = json.loads(event.get("body") or "{}")
        new_task = body.get("task")

        if not task_id or not new_task:
            return build_response(400, {"message": "Task ID and new task are required"})

        table.update_item(
            Key={"id": task_id},
            UpdateExpression="SET #t = :val",
            ExpressionAttributeNames={"#t": "task"},
            ExpressionAttributeValues={":val": new_task}
        )

        return build_response(200, {"message": "Task updated"})

    except Exception as e:
        return build_response(500, {"error": str(e)})
