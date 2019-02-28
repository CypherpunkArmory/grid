#!/bin/bash

# login to vault with the IAM profile of the host
echo "Getting Nomad Token from Vault"

export VAULT_ADDR=http://vault:8200

# don't put the token in the log
vault login -method=aws header_value=vault role=city-host > /dev/null
TOKEN=$(vault token create -role=nomad-server -field=token)

sed -i "s/<TOKEN>/$TOKEN/" /etc/nomad.hcl
