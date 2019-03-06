#!/bin/bash
echo "VAULT_TOKEN=$(vault login -method=aws -field=token header_value=vault role=lb-host)" > /etc/fabio.env
