#!/bin/bash
CREDS=$(vault read azure/creds/$1 -format=json)
export ARM_CLIENT_ID=$(echo $CREDS | jq -r '.data.client_id')
export ARM_CLIENT_SECRET=$(echo $CREDS | jq -r '.data.client_secret')
export ARM_SUBSCRIPTION_ID=2bcf5102-4ec5-425f-b854-d95c559fb14a
export ARM_TENANT_ID=804a3a6f-55f6-48dd-9a75-3d1c29da9fb8
COMMAND="az login --service-principal -u $ARM_CLIENT_ID -p $ARM_CLIENT_SECRET --tenant $ARM_TENANT_ID"
sleep 10
sh -c "$COMMAND"
