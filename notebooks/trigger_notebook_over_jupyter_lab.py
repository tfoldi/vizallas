# Execute a notebook over Jupyter Lab API
#
# Based on https://stackoverflow.com/a/54551221/942520


import json
import requests
import datetime
import uuid
import os
from pprint import pprint
from websocket import create_connection, WebSocketTimeoutException

# Notebook path on Jupyter server with a leading slash
notebook_path = "/Vizallas.ipynb"
# Either http or https
protocol = "http"
# Jupyter server address and port
base = "localhost:8888"
headers = {"Authorization": f"Token {os.environ['JUPYTER_TOKEN']}"}

# Create a kernel
url = f"{protocol}://{base}/api/kernels"
print("Creating a new kernel")
response = requests.post(url, headers=headers)
kernel = json.loads(response.text)

# Load the notebook and get the code of each cell
url = f"{protocol}://{base}/api/contents{notebook_path}"
response = requests.get(url, headers=headers)
file = json.loads(response.text)
# filter out non-code cells like markdown
code = [
    c["source"]
    for c in file["content"]["cells"]
    if len(c["source"]) > 0 and c["cell_type"] == "code"
]

# Execution request/reply is done on websockets channels
ws = create_connection(
    f"{'ws' if protocol == 'http' else 'wss'}://{base}/api/kernels/{kernel['id']}/channels",
    header=headers,
)


def send_execute_request(code):
    msg_type = "execute_request"
    content = {"code": code, "silent": False}
    hdr = {
        "msg_id": uuid.uuid1().hex,
        "username": "test",
        "session": uuid.uuid1().hex,
        "data": datetime.datetime.now().isoformat(),
        "msg_type": msg_type,
        "version": "5.0",
    }
    msg = {"header": hdr, "parent_header": hdr, "metadata": {}, "content": content}
    pprint(code)
    return msg


print("Sending execution requests for each cell")
for c in code:
    ws.send(json.dumps(send_execute_request(c)))

code_blocks_to_execute = len(code)

while code_blocks_to_execute > 0:
    try:
        rsp = json.loads(ws.recv())
        msg_type = rsp["msg_type"]
        if msg_type == "error":
            raise Exception(rsp["content"]["traceback"][0])
    except WebSocketTimeoutException as _e:
        pprint(_e)
        break
    print(f"Received message of type {msg_type} with text {rsp['content'].get('text')}")

    pprint(rsp)
    if (
        msg_type == "execute_reply"
        and rsp["metadata"].get("status") == "ok"
        and rsp["metadata"].get("dependencies_met", False)
    ):
        code_blocks_to_execute -= 1


print("Processing finished. Closing websocket connection")
ws.close()

# Delete the kernel
pprint(kernel)
print("Deleting kernel")
url = f"{protocol}://{base}/api/kernels/{kernel['id']}"
response = requests.delete(url, headers=headers)
