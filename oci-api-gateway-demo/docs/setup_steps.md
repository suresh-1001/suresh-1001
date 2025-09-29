# Setup Steps

## Option A: Terraform
1. Set provider auth (resource principal / API key / CLI config).
2. Fill `terraform.tfvars` with:
   - `tenancy_ocid`, `compartment_ocid`
   - `subnet_id` for Gateway
   - `backend_url` (e.g., http://10.0.1.10:8080/health via private LB)
3. `terraform init && terraform apply`

## Option B: OCI CLI
- Set `OCI_CLI_PROFILE` in `scripts/deploy-cli.sh`, then run it.

## Verify
- Hit the Gateway endpoint path `/health`
- Check logs/metrics in API Gateway & OCI Logging.

