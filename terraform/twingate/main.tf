# Configure the Civo Provider
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


provider "civo" {
  token = var.civo_token
}

provider "twingate" {
  api_token = var.twingate_token
  network   = "keith"
}

data "civo_instances_size" "medium" {
    filter {
        key = "type"
        values = ["kubernetes"]
    }

    sort {
        key = "ram"
        direction = "asc"
    }
}

#output "instances" {
#  value       = data.civo_instances_size.small.sizes
#  description = "The Civo Instances."
#}

resource "civo_kubernetes_cluster" "my-cluster" {
    name = "my-cluster"
    applications = "Ghost:5GB"
    num_target_nodes = 3
    target_nodes_size = element(data.civo_instances_size.medium.sizes, 2).name
}

data "civo_kubernetes_cluster" "my-cluster" {
    name = civo_kubernetes_cluster.my-cluster.name
}

#output "kubernetes_cluster_output" {
#  value = data.civo_kubernetes_cluster.my-cluster.kubeconfig
#}

resource "local_file" "private_key" {
    content  = data.civo_kubernetes_cluster.my-cluster.kubeconfig
    filename = "ignore/civo.conf"
}


resource "twingate_remote_network" "civo_network" {
  name = "civo_remote_network"
}

output "twingate_remote_network" {
  value = data.civo_kubernetes_cluster.my-cluster.kubeconfig
}

resource "twingate_connector" "civo_connector" {
  remote_network_id = twingate_remote_network.civo_network.id
}

resource "twingate_connector_tokens" "civo_connector_tokens" {
  connector_id = twingate_connector.civo_connector.id
}

#data "twingate_connector_tokens" "civo_connector" {
 #   name = "civo_connector"
#}

output "twingate_access_token_output" {
  value = twingate_remote_network.civo_network.id

}

output "twingate_refresh_token_output" {
  value = twingate_connector_tokens.civo_connector_tokens.refresh_token 
  sensitive = true
}


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
    value = "keith"
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



resource "twingate_resource" "resource" {
  name = "network"
  address = "ghost-blog.ghost.svc.cluster.local"
  remote_network_id = twingate_remote_network.civo_network.id
}