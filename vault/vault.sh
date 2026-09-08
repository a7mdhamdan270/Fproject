#!/bin/bash

VAULT_ADDR='http://127.0.0.1:8200'
VAULT_TOKEN='${VAULT_TOKEN}'
SECRET_PATH='secret/data/webapp'
ENV_FILE='/Fproject/.env'

export VAULT_ADDR
export VAULT_TOKEN

echo "Retrieving secrets from Vault..."
SECRETS=$(docker exec -e VAULT_ADDR="$VAULT_ADDR" -e VAULT_TOKEN="$VAULT_TOKEN" vault-skills vault kv get -format=json secret/webapp 2>/dev/null)

if [ -z "$SECRETS" ]; then
  echo "Failed to retrieve secrets from Vault."
  exit 1
fi

echo "Saving secrets to $ENV_FILE..."
echo "$SECRETS" | jq -r '.data.data | to_entries[] | .key + "=" + (.value|tostring)' > "$ENV_FILE"

if [ $? -eq 0 ]; then
  echo "Successfully created $ENV_FILE!"
  echo "Running Docker containers..."
  docker compose up -d
else
  echo "Failed to process secrets with jq."
  exit 1
fi
