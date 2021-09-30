# Set the Providers
terraform {
  required_providers {
    civo = {
      source = "civo/civo"
      version = "0.10.11"
    }
    twingate = {
      source = "twingate/twingate"
      version = "0.1.5"
    }
    helm = {
      source = "hashicorp/helm"
      version = "2.3.0"
    }
    }
}

# Provider tokens
provider "civo" {
  token = var.civo_token
}

provider "twingate" {
  api_token = var.twingate_token
  network   = var.network
}

# Get instance sizes from Civo and order by ram
data "civo_instances_size" "instances" {
    filter {
        key = "type"
        values = ["kubernetes"]
    }

    sort {
        key = "ram"
        direction = "asc"
    }
}
# New cluster with the name "my-cluster", with 3 nodes and taking the 3rd instance size from the list generated above
resource "civo_kubernetes_cluster" "my-cluster" {
    name = "my-cluster"
    applications = "Ghost:5GB"
    num_target_nodes = 3
    target_nodes_size = element(data.civo_instances_size.instances.sizes, 2).name
}

# Return the name of the newly generated cluster
data "civo_kubernetes_cluster" "my-cluster" {
    name = civo_kubernetes_cluster.my-cluster.name
}

# Store the cluster config in the ignore directory
resource "local_file" "private_key" {
    content  = data.civo_kubernetes_cluster.my-cluster.kubeconfig
    filename = "ignore/civo.conf"
}

# Setup a new remote network on Twingate
resource "twingate_remote_network" "civo_network" {
  name = "civo_remote_network"
}

# Create the new twingate connector
resource "twingate_connector" "civo_connector" {
  remote_network_id = twingate_remote_network.civo_network.id
}

# Create the tokens for the new connector
resource "twingate_connector_tokens" "civo_connector_tokens" {
  connector_id = twingate_connector.civo_connector.id
}


#output "twingate_access_token_output" {
#  value = twingate_remote_network.civo_network.id

#}

#output "twingate_refresh_token_output" {
#  value = twingate_connector_tokens.civo_connector_tokens.refresh_token 
#  sensitive = true
#}

# Deploy the connector to the new k8s cluster via helm
provider "helm" {
  kubernetes {
    config_path = local_file.private_key.filename
  }
}

resource "helm_release" "twingate_connector" {
  name       = "connector"
  repository = "https://twingate.github.io/helm-charts"
  chart      = "connector"
  version = "0.1.8"

  set {
    name  = "connector.network"
    value = var.network
  }
  set {
    name  = "connector.accessToken"
    value = twingate_connector_tokens.civo_connector_tokens.access_token
  }  
  set {
    name  = "connector.refreshToken"
    value = twingate_connector_tokens.civo_connector_tokens.refresh_token
  }    
}

# Add a new resouce to twingate
resource "twingate_resource" "resource" {
  name = "ghost"
  address = "ghost-blog.ghost.svc.cluster.local"
  remote_network_id = twingate_remote_network.civo_network.id
  group_ids = [var.groupID]
}