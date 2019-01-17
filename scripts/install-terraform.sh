#!/bin/bash

readonly TERRAFORM_VERSION="0.11.10"
readonly INSTALL_DIR="/usr/local/bin"
readonly DOWNLOAD_DIR="/tmp"
readonly DOWNLOAD_URL="https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip"
readonly DOWNLOADED_FILE="$DOWNLOADED_DIR/terraform.zip"

echo ""
echo "Downloading Terraform ${TERRAFORM_VERSION}..."
curl -o "$DOWNLOADED_FILE" "$DOWNLOAD_URL"
echo ""
echo "Extracting Terraform to ${INSTALL_DIR}..."
unzip "$DOWNLOADED_FILE" -d "$INSTALL_DIR"
echo ""
echo "Cleaning up..."
rm "$DOWNLOADED_FILE"
