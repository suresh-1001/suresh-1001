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
