FROM jupyter/base-notebook

COPY notebooks/requirements.txt /home/jovyan/workspaces/
COPY notebooks/*.ipynb /home/jovyan/workspaces/

USER root
RUN apt-get update --yes && apt-get install --yes libpq-dev gcc && apt-get clean && rm -rf /var/lib/apt/lists/*
RUN pip install -r /home/jovyan/workspaces/requirements.txt
USER $NB_UID
