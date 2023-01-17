variable "civo_token" {}

# Specify required provider as maintained by civo
terraform {
  required_providers {
    civo = {
      source = "civo/civo"
    }
  }
}

data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
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

# Create a firewall for the database and an access rule for the cluster to access the db
resource "civo_firewall" "demo-firewall-db" {
    name = "demo-firewall-db"
    create_default_rules = false
    ingress_rule {
        label = "k8s access"
        protocol = "tcp"
        port_range = "3306"
        cidr = [format("%s/%s",civo_kubernetes_cluster.demo-cluster.master_ip,"32")]
        action = "allow"
    }
        ingress_rule {
        label = "personal access"
        protocol = "tcp"
        port_range = "3306"
        cidr = ["${chomp(data.http.myip.response_body)}/32"]
        action = "allow"
    }
    
}

# Create a cluster
resource "civo_kubernetes_cluster" "demo-cluster" {
    # name = "" # Specify a name if you like, I enjoy seeing the random ones! 
    # applications = "" 
    firewall_id = civo_firewall.demo-firewall-k8s.id
    pools {
        label = "demo-pool" // Optional
        size = element(data.civo_size.medium.sizes, 0).name
        node_count = 3
    }
     provisioner "local-exec" {
    command = "civo k3s config ${civo_kubernetes_cluster.demo-cluster.name} --save --merge"
    
  }
}

output "cluster_name" {
  value = civo_kubernetes_cluster.demo-cluster.name
}
