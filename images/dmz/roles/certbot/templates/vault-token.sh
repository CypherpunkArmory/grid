#!/bin/bash

# login to vault with the IAM profile of the host
echo "Getting DMZ Token from Vault"

export VAULT_ADDR=http://vault:8200

# don't put the token in the log
vault login -method=aws header_value=vault role=dmz-host > /dev/null
TOKEN=$(vault token create -role=certbot -field=token)

echo -n $TOKEN >> "/home/certbot/.vault-token"
