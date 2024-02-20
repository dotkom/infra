#!/bin/bash
SECRET=$(vault write -format=json -force pki_int/issue/consul-client "ttl=768h" "common_name=client.consul")

FILE_NAME=$(uuidgen)

touch ~/.consul/client.key
touch ~/.consul/client.crt
touch ~/.consul/ca.crt

echo $SECRET | jq -r '.data.certificate' > ~/.consul/client.crt
echo $SECRET | jq -r '.data.private_key' > ~/.consul/client.key
echo $SECRET | jq -r '.data.issuing_ca' > ~/.consul/ca.crt
