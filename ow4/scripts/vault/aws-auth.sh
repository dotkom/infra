#!/bin/bash

CREDS=$(vault read aws/creds/$1 -format=json)
export AWS_SECRET_ACCESS_KEY=$(echo $CREDS | jq -r '.data.secret_key')
export AWS_ACCESS_KEY_ID=$(echo $CREDS | jq -r '.data.access_key')
