variable "civo_token" {}

# Specify required provider as maintained by civo
terraform {
  required_providers {
    civo = {
      source = "civo/civo"
    }
  }
}

# Configure the Civo Provider
provider "civo" {
  token = var.civo_token
  region = "LON1"
}

data "civo_size" "medium" {
    filter {
        key = "name"
        values = ["g4s.kube.medium"]
    }

    sort {
        key = "ram"
        direction = "asc"
    }
}

# Create a firewall for the cluster
resource "civo_firewall" "demo-firewall-k8s" {
    name = "demo-firewall-k8s"
}

# Create a firewall for the database
resource "civo_firewall" "demo-firewall-db" {
    name = "demo-firewall-db"
}


# Create a cluster
resource "civo_kubernetes_cluster" "my-cluster" {
    name = "demo-cluster"
    # applications = ""
    firewall_id = civo_firewall.demo-firewall-k8s.id
    pools {
        label = "demo-pool" // Optional
        size = element(data.civo_size.medium.sizes, 0).name
        node_count = 3
    }
}

