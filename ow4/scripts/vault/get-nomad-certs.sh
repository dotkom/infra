#!/bin/bash
SECRET=$(vault write -format=json -force pki_int/issue/nomad-client "ttl=768h" "common_name=client.global.nomad")

FILE_NAME=$(uuidgen)

touch ~/.nomad/client.key
touch ~/.nomad/client.crt
touch ~/.nomad/ca.crt

echo $SECRET | jq -r '.data.certificate' > ~/.nomad/client.crt
echo $SECRET | jq -r '.data.private_key' > ~/.nomad/client.key
echo $SECRET | jq -r '.data.issuing_ca' > ~/.nomad/ca.crt
