#!/bin/bash

VAULT_ADDR="${VAULT_ADDR:-http://host.docker.internal:8200}"
VAULT_TOKEN="${VAULT_TOKEN}"
SECRET_PATH='secret/webapp'
ENV_FILE='/Fproject/.env'

export VAULT_ADDR
export VAULT_TOKEN

echo "Retrieving secrets from Vault..."
SECRETS=$(vault kv get -format=json $SECRET_PATH 2>/dev/null)

if [ -z "$SECRETS" ]; then
  echo "Failed to retrieve secrets from Vault."
  exit 1
fi

echo "Saving secrets to $ENV_FILE..."
echo "$SECRETS" | jq -r '.data.data | to_entries[] | .key + "=" + (.value|tostring)' > "$ENV_FILE"

if [ $? -eq 0 ]; then
  echo "Successfully created $ENV_FILE!"
else
  echo "Failed to process secrets with jq."
  exit 1
fi
