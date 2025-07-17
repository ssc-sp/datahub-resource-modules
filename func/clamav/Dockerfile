FROM python:3.12-bookworm

ENV DataHub_ENVNAME=dev \   
    AzureTenantId= \
    AzureSubscriptionId= \
    AzureWebJobsFeatureFlags=EnableWorkerIndexing \
    AzureWebJobsDashboard= \
    storage_connection_string= \
    queue_name=virus-scan \
    container_name=datahub \
    quarantine_container_name=datahub-quarantine 

RUN apt update && apt install -y clamav clamav-daemon curl wget unzip python3-venv && rm -rf /var/lib/apt/lists/*
RUN freshclam
COPY app/* /app/

WORKDIR /app

CMD ["bash", "/app/entrypoint.sh"]
