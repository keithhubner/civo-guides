# Configure the Civo Provider
# Configure the Civo Provider
terraform {
  required_providers {
    civo = {
      source = "civo/civo"
      version = "0.10.3"
    }
  }
}

provider "civo" {
  token = var.civo_token
}


resource "civo_kubernetes_cluster" "my-cluster" {
    name = "sammy"
    region = "LON1"
    applications = "Rancher"
    num_target_nodes = 3
    target_nodes_size = "g3.k3s.xsmall"
}