#!/usr/bin/env bash
# Deletes everything provision.sh created (one resource group).
set -euo pipefail
az group delete -n "${RG:-tollgate-xdp-live}" --yes --no-wait
echo "deleting resource group ${RG:-tollgate-xdp-live}"
