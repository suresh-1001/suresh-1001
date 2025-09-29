# go to your profile repo
cd ~/github/suresh-1001

# create the missing folders
mkdir -p oci-api-gateway-demo/infra/terraform

# providers.tf
cat > oci-api-gateway-demo/infra/terraform/providers.tf <<'EOF'
terraform {
  required_version = ">= 1.4.0"
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 5.0.0"
    }
  }
}
provider "oci" {}
EOF

# variables.tf
cat > oci-api-gateway-demo/infra/terraform/variables.tf <<'EOF'
variable "compartment_ocid" { type = string }
variable "subnet_id"        { type = string } # Subnet for API Gateway
variable "display_name"     { type = string  default = "api-gw-demo" }
variable "backend_url"      { type = string  default = "http://10.0.1.10:8080" }
variable "certificate_id"   { type = string  default = null } # Optional OCI cert OCID
EOF

# main.tf
cat > oci-api-gateway-demo/infra/terraform/main.tf <<'EOF'
data "oci_core_subnet" "gw_subnet" { subnet_id = var.subnet_id }

resource "oci_apigateway_gateway" "gw" {
  compartment_id = var.compartment_ocid
  endpoint_type  = "PUBLIC"
  subnet_id      = var.subnet_id
  display_name   = var.display_name
  certificate_id = var.certificate_id
}

resource "oci_apigateway_deployment" "dep" {
  compartment_id = var.compartment_ocid
  gateway_id     = oci_apigateway_gateway.gw.id
  path_prefix    = "/"
  display_name   = "${var.display_name}-deployment"

  specification {
    routes {
      path    = "/health"
      methods = ["GET"]
      backend {
        type = "HTTP_BACKEND"
        url  = "${var.backend_url}/health"
      }
    }
  }
}

output "gateway_id"    { value = oci_apigateway_gateway.gw.id }
output "deployment_id" { value = oci_apigateway_deployment.dep.id }
EOF

# terraform.tfvars (placeholders you’ll edit later)
cat > oci-api-gateway-demo/infra/terraform/terraform.tfvars <<'EOF'
# Fill these before apply
compartment_ocid = "ocid1.compartment.oc1..xxxx"
subnet_id        = "ocid1.subnet.oc1..xxxx"
# Optional:
# certificate_id   = "ocid1.certificate.oc1..xxxx"
# backend_url      = "http://10.0.1.10:8080"
EOF

# commit & push
git add oci-api-gateway-demo/infra/terraform
git commit -m "feat(oci): add infra/terraform for API Gateway demo"
git pull --rebase origin main || true
git push origin main
