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
