variable "compartment_ocid" { type = string }
variable "subnet_id"        { type = string } # Subnet for API Gateway
variable "display_name"     { type = string  default = "api-gw-demo" }
variable "backend_url"      { type = string  default = "http://10.0.1.10:8080" }
variable "certificate_id"   { type = string  default = null } # Optional OCI cert OCID
