#!/usr/bin/env bash
set -euo pipefail

# Set your OCI CLI profile
PROFILE="${OCI_CLI_PROFILE:-DEFAULT}"
COMPARTMENT_OCID="${COMPARTMENT_OCID:-ocid1.compartment.oc1..xxxx}"
SUBNET_ID="${SUBNET_ID:-ocid1.subnet.oc1..xxxx}"
DISPLAY_NAME="${DISPLAY_NAME:-api-gw-demo}"
BACKEND_URL="${BACKEND_URL:-http://10.0.1.10:8080}"
CERT_ID="${CERT_ID:-}"

echo "Using profile: $PROFILE"

# Create API Gateway
GW_JSON=$(oci --profile "$PROFILE" api-gateway gateway create \
  --compartment-id "$COMPARTMENT_OCID" \
  --endpoint-type PUBLIC \
  --subnet-id "$SUBNET_ID" \
  --display-name "$DISPLAY_NAME" \
  ${CERT_ID:+--certificate-id "$CERT_ID"} \
  --wait-for-state ACTIVE \
  --query 'data')

GW_ID=$(jq -r '.id' <<<"$GW_JSON")
echo "Gateway ID: $GW_ID"

# Create a deployment for /health -> BACKEND_URL/health
SPEC=$(jq -n --arg url "$BACKEND_URL" '{
  "routes": [{
    "path": "/health",
    "methods": ["GET"],
    "backend": { "type":"HTTP_BACKEND", "url": ($url + "/health") }
  }]
}')
DEP_JSON=$(oci --profile "$PROFILE" api-gateway deployment create \
  --compartment-id "$COMPARTMENT_OCID" \
  --gateway-id "$GW_ID" \
  --path-prefix "/" \
  --display-name "${DISPLAY_NAME}-deployment" \
  --specification "$SPEC" \
  --wait-for-state ACTIVE \
  --query 'data')

echo "$DEP_JSON" | jq
