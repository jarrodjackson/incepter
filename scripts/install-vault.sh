#!/bin/bash

readonly VAULT_VERSION="1.0.2"
readonly INSTALL_DIR="/usr/local/bin"
readonly DOWNLOAD_DIR="/tmp"
readonly DOWNLOAD_URL="https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip"
readonly DOWNLOADED_FILE="$DOWNLOADED_DIR/vault.zip"

echo ""
echo "Downloading Vault ${VAULT_VERSION}..."
curl -o "$DOWNLOADED_FILE" "$DOWNLOAD_URL"
echo ""
echo "Extracting Vault to ${INSTALL_DIR}..."
unzip "$DOWNLOADED_FILE" -d "$INSTALL_DIR"
echo ""
echo "Cleaning up..."
rm "$DOWNLOADED_FILE"
