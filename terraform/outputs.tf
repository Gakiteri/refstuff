output "resource_group_name" {
  value = azurerm_resource_group.rg-01.name
}

output "kubernetes_cluster_name" {
  value = azurerm_kubernetes_cluster.kube-01.name
}
