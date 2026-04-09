terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>4.65.0"
    }
  }
}

provider "azurerm" {
  features {}
  resource_provider_registrations = "none"
}

variable "resource_group_name" { default = "devsecops" }
//variable "location" { default = "mexicocentral" }
variable "cluster_name" { default = "devsecops" }

/*resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}*/

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  dns_prefix          = "devsecops-dns"
  kubernetes_version  = "1.33.5"



  default_node_pool {
    name                = "default"
    node_count          = 3
    vm_size             = "Standard_D2_v3"
    auto_scaling_enabled = true
    min_count           = 3
    max_count           = 5
  
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    network_data_plane   = "azure"
    load_balancer_sku   = "standard"
  }

  auto_scaler_profile {
    balance_similar_node_groups      = true
    empty_bulk_delete_max            = 10
    expander                         = "priority"
    max_graceful_termination_sec     = 600
    max_node_provisioning_time          = "15m"
    max_unready_percentage     = 45
    new_pod_scale_up_delay           = "0s"
    //scale_down_enabled               = true
    scale_down_delay_after_add       = "10m"
    scale_down_delay_after_delete    = "10s"
    scale_down_unneeded              = "10m"
    skip_nodes_with_local_storage    = true
    skip_nodes_with_system_pods      = true
  }

  /*azure_active_directory_role_based_access_control {
    azure_rbac_enabled = false
  }*/
  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  monitor_metrics {
    annotations_allowed = null
    labels_allowed      = null
  }
}

/*resource "azurerm_role_assignment" "aks_identity" {
  scope              = azurerm_resource_group.rg.id
  role_definition_name = "Contributor"
  principal_id       = azurerm_kubernetes_cluster.aks.identity[0].principal_id
}*/

output "kube_config" {
  value     = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive = true
}

output "cluster_name" {
  value = azurerm_kubernetes_cluster.aks.name
}

output "resource_group_name" {
  value = data.azurerm_resource_group.rg.name
}

output "aks_id" {
  value = azurerm_kubernetes_cluster.aks.id
}

/*output "oidc_issuer_url" {
  value = azurerm_kubernetes_cluster.aks.oidc_issuer_enabled ? azurerm_kubernetes_cluster.aks.oidc_issuer_url[0] : null
}*/