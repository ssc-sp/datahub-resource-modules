import azure.functions as func
import logging  
import os, uuid
from azure.identity import DefaultAzureCredential
from azure.storage.queue import QueueClient
import json

app = func.FunctionApp()

def get_config():
    storage_connection_string = os.getenv("AzureWebJobsStorage")
    queue_name = os.getenv("queue_name") or "virus-scan"
    container_name = os.getenv("container_name") or "datahub"
    return storage_connection_string, queue_name, container_name

storage_connection_string, queue_name, container_name = get_config()

@app.function_name(name="BlobEnqueue")
@app.blob_trigger(arg_name="client", path=container_name,
                               connection="AzureWebJobsStorage") 
def blob_enqueue(client: func.InputStream):
    logging.info(f"Python blob trigger function processed blob"
                f"Name: {client.name}"
                f"Blob Size: {client.length} bytes")
    
    blob_parts = client.name.split(os.sep)  
    blob_path_in_container = os.path.join(*blob_parts[1:])

    try:        
        if isinstance(client.length, int):  # test if it is a file not directory
            queue_client = QueueClient.from_connection_string(conn_str=storage_connection_string, queue_name=queue_name)
            json_message = {"blobName": blob_path_in_container, "blobUri": client.uri, "blobSize": client.length}
            queue_client.send_message(json.dumps(json_message))
            print(f"Enqueued JSON message: '{json.dumps(json_message)}'")

    except Exception as ex:
        print(f"Error: {ex}")