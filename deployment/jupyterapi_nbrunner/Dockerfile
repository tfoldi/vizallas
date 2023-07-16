FROM python:3.11-alpine

RUN pip install --no-cache-dir requests websocket-client
COPY notebooks/trigger_notebook_over_jupyter_lab.py .

USER 1000

ENTRYPOINT [ "python", "./trigger_notebook_over_jupyter_lab.py" ]
