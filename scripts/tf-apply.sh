#!/bin/bash
cd terraform
terraform apply -auto-approve \
    -var="environment=dev" \
    -var="account_id=${CLOUDFLARE_ACCOUNT_ID}"
cd ../