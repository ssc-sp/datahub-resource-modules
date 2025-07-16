FROM python:3.12 AS build

COPY requirements.txt /

RUN pip install --upgrade pip
RUN pip install -r ./requirements.txt  --target="/home/.local/lib/python3.12/site-packages" --no-cache-dir --upgrade

FROM mcr.microsoft.com/azure-functions/python:4-python3.12

ENV AzureWebJobsScriptRoot=/home/site/wwwroot \
    AzureFunctionsJobHost__Logging__Console__IsEnabled=true \
    APPLICATIONINSIGHTS_CONNECTION_STRING= \
    DataHub_ENVNAME=dev \   
    AzureWebJobsStorage= \   
    AzureTenantId= \
    AzureSubscriptionId= \
    AzureWebJobsFeatureFlags=EnableWorkerIndexing \
    AzureWebJobsDashboard= \
    storage_connection_string= \
    queue_name= \
    container_name=datahub

COPY --from=build /home/.local/lib/python3.12/site-packages /home/.local/lib/python3.12/site-packages

COPY . /home/site/wwwroot