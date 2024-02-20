#!/bin/bash
SECRET=$(vault write -format=json -force pki_int/issue/operator)

FILE_NAME=$(uuidgen)

touch $FILE_NAME.key
touch $FILE_NAME.crt

echo $SECRET | jq -r '.data.certificate' > $FILE_NAME.crt
echo $SECRET | jq -r '.data.private_key' > $FILE_NAME.key

openssl pkcs12 -export -in $FILE_NAME.crt -inkey $FILE_NAME.key -out bundle.p12

rm $FILE_NAME.crt
rm $FILE_NAME.key
