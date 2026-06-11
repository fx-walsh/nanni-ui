#!/bin/bash
cd terraform/
terraform init \
    -backend-config="access_key=${R2_ACCESS_KEY}" \
    -backend-config="secret_key=${R2_SECRET_ACCESS_KEY}"
cd ../